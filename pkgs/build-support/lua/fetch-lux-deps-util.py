"""
Utility script to fetch Lux dependencies from a lux.lock file.
This script parses the lock file and downloads all dependencies
to a vendor directory structure that Lux expects.
"""

import functools
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path
from typing import Any, TypedDict
from urllib.parse import urlparse

import requests
from requests.adapters import HTTPAdapter, Retry

eprint = functools.partial(print, file=sys.stderr)


def load_json(path: Path) -> dict[str, Any]:
    """Load a JSON file."""
    with open(path, "r") as f:
        return json.load(f)


def create_http_session() -> requests.Session:
    """Create an HTTP session with retry logic."""
    retries = Retry(
        total=5,
        backoff_factor=0.5,
        status_forcelist=[500, 502, 503, 504]
    )
    session = requests.Session()
    session.mount('http://', HTTPAdapter(max_retries=retries))
    session.mount('https://', HTTPAdapter(max_retries=retries))
    return session


def download_file(session: requests.Session, url: str, destination_path: Path) -> None:
    """Download a file from a URL to a destination path."""
    eprint(f"Downloading {url} to {destination_path}")
    destination_path.parent.mkdir(parents=True, exist_ok=True)

    with session.get(url, stream=True, timeout=60) as response:
        response.raise_for_status()
        with open(destination_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)


def verify_hash(file_path: Path, expected_hash: str) -> bool:
    """Verify the SHA256 hash of a file."""
    if not expected_hash or not expected_hash.startswith('sha256-'):
        return True  # Skip verification if no hash provided

    # Convert base64 hash to hex
    import base64
    expected_hex = base64.b64decode(expected_hash.split('-', 1)[1]).hex()

    sha256_hash = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            sha256_hash.update(chunk)

    actual_hex = sha256_hash.hexdigest()
    return actual_hex == expected_hex


def extract_archive(archive_path: Path, extract_to: Path) -> None:
    """Extract an archive (tar.gz, zip) to a directory."""
    eprint(f"Extracting {archive_path} to {extract_to}")
    extract_to.mkdir(parents=True, exist_ok=True)

    if archive_path.suffix == '.gz' and '.tar' in archive_path.name:
        with tarfile.open(archive_path, 'r:gz') as tar:
            tar.extractall(extract_to)
    elif archive_path.suffix == '.zip':
        with zipfile.ZipFile(archive_path, 'r') as zip_file:
            zip_file.extractall(extract_to)
    elif archive_path.suffix == '.tar':
        with tarfile.open(archive_path, 'r:') as tar:
            tar.extractall(extract_to)
    else:
        eprint(f"Warning: Unknown archive format: {archive_path}")


def clone_git_repo(url: str, ref: str, dest: Path) -> None:
    """Clone a git repository at a specific revision."""
    eprint(f"Cloning git repo {url} at {ref} to {dest}")
    dest.parent.mkdir(parents=True, exist_ok=True)

    # Use nix-prefetch-git if available for better Nix integration
    try:
        result = subprocess.run(
            ['nix-prefetch-git', '--url', url, '--rev', ref, '--quiet'],
            capture_output=True,
            text=True,
            check=True,
            timeout=300
        )
        info = json.loads(result.stdout)

        # Copy the fetched git repo to the destination
        if os.path.exists(info['path']):
            shutil.copytree(info['path'], dest, dirs_exist_ok=True)
        return
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired, KeyError) as e:
        eprint(f"nix-prefetch-git failed: {e}, falling back to git clone")

    # Fallback to regular git clone
    try:
        subprocess.run(['git', 'clone', '--depth', '1', '--branch', ref, url, str(dest)],
                      check=True, timeout=300)
    except subprocess.CalledProcessError:
        # If branch doesn't work, try as a commit hash
        subprocess.run(['git', 'clone', url, str(dest)], check=True, timeout=300)
        subprocess.run(['git', '-C', str(dest), 'checkout', ref], check=True, timeout=60)

    # Remove .git directory to save space
    git_dir = dest / '.git'
    if git_dir.exists():
        shutil.rmtree(git_dir, ignore_errors=True)


class LuxDependency(TypedDict):
    """Represents a Lux dependency."""
    hash_id: str
    name: str
    version: str
    source_type: str  # 'url' or 'git'
    source_url: str
    source_ref: str | None  # for git repos
    expected_hash: str | None


def parse_lux_lock(lock_path: Path) -> list[LuxDependency]:
    """Parse a lux.lock file and extract dependency information."""
    eprint(f"Parsing lock file: {lock_path}")

    lock_data = load_json(lock_path)

    dependencies = []

    # Parse both regular dependencies and test dependencies
    for dep_category in ['dependencies', 'test_dependencies']:
        if dep_category not in lock_data:
            continue

        rocks = lock_data[dep_category].get('rocks', {})

        for hash_id, dep_info in rocks.items():
            source_url_info = dep_info.get('source_url', {})
            source_type = source_url_info.get('type', 'url')

            dep = LuxDependency(
                hash_id=hash_id,
                name=dep_info['name'],
                version=dep_info['version'],
                source_type=source_type,
                source_url=source_url_info.get('url', ''),
                source_ref=source_url_info.get('ref') if source_type == 'git' else None,
                expected_hash=dep_info.get('hashes', {}).get('source')
            )
            dependencies.append(dep)

    eprint(f"Found {len(dependencies)} dependencies")
    return dependencies


def fetch_url_dependency(session: requests.Session, dep: LuxDependency, vendor_dir: Path) -> None:
    """Fetch a dependency from a URL."""
    dep_dir = vendor_dir / dep['name'] / dep['version']

    if dep_dir.exists():
        eprint(f"  Dependency {dep['name']}-{dep['version']} already exists, skipping")
        return

    # Determine archive filename from URL
    url = dep['source_url']
    parsed_url = urlparse(url)
    filename = os.path.basename(parsed_url.path)

    # If filename doesn't have an extension, guess from URL or use .tar.gz
    if not any(filename.endswith(ext) for ext in ['.zip', '.tar.gz', '.tgz', '.tar']):
        if 'zip' in url.lower():
            filename = f"{dep['name']}-{dep['version']}.zip"
        else:
            filename = f"{dep['name']}-{dep['version']}.tar.gz"

    archive_file = vendor_dir / filename

    # Download the file
    download_file(session, url, archive_file)

    # Verify hash if provided
    if dep['expected_hash']:
        if not verify_hash(archive_file, dep['expected_hash']):
            eprint(f"Warning: Hash mismatch for {dep['name']}-{dep['version']}")

    # Extract the archive
    temp_extract = vendor_dir / f"temp_{dep['name']}_{dep['version']}"
    extract_archive(archive_file, temp_extract)

    # Find the actual content directory (often archives have a top-level directory)
    extracted_items = list(temp_extract.iterdir())
    if len(extracted_items) == 1 and extracted_items[0].is_dir():
        # Single top-level directory, move its contents
        shutil.move(str(extracted_items[0]), str(dep_dir))
    else:
        # Multiple items or files, move the temp directory itself
        shutil.move(str(temp_extract), str(dep_dir))

    # Clean up
    if temp_extract.exists():
        shutil.rmtree(temp_extract, ignore_errors=True)
    archive_file.unlink(missing_ok=True)


def fetch_git_dependency(dep: LuxDependency, vendor_dir: Path) -> None:
    """Fetch a dependency from a git repository."""
    dep_dir = vendor_dir / dep['name'] / dep['version']

    if dep_dir.exists():
        eprint(f"  Dependency {dep['name']}-{dep['version']} already exists, skipping")
        return

    clone_git_repo(dep['source_url'], dep['source_ref'], dep_dir)


def fetch_dependency(session: requests.Session, dep: LuxDependency, vendor_dir: Path) -> None:
    """Fetch a single dependency."""
    eprint(f"Fetching dependency: {dep['name']} {dep['version']} (type: {dep['source_type']})")

    try:
        if dep['source_type'] == 'git':
            fetch_git_dependency(dep, vendor_dir)
        else:  # 'url' or other
            fetch_url_dependency(session, dep, vendor_dir)
        eprint(f"  Successfully fetched {dep['name']}-{dep['version']}")
    except Exception as e:
        eprint(f"  Error fetching {dep['name']}-{dep['version']}: {e}")
        raise


def create_vendor_staging(lock_file: Path, output_dir: Path) -> None:
    """Create a staging directory with all dependencies fetched."""
    eprint(f"Creating vendor staging directory: {output_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)

    dependencies = parse_lux_lock(lock_file)

    if not dependencies:
        eprint("Warning: No dependencies found in lock file")
        return

    session = create_http_session()

    # Fetch dependencies sequentially to avoid overwhelming the system
    # (parallel fetching can be added back if needed, but git clones can be heavy)
    for dep in dependencies:
        try:
            fetch_dependency(session, dep, output_dir)
        except Exception as e:
            eprint(f"Failed to fetch {dep['name']}: {e}")
            # Continue with other dependencies instead of failing completely
            continue

    eprint("Vendor staging directory created successfully")


def create_vendor(staging_dir: Path, output_dir: Path) -> None:
    """Create the final vendor directory from staging."""
    eprint(f"Creating vendor directory: {output_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)

    # Copy the staging directory to the output
    if staging_dir.exists():
        for item in staging_dir.iterdir():
            dest = output_dir / item.name
            if item.is_dir():
                shutil.copytree(item, dest, dirs_exist_ok=True)
            else:
                shutil.copy2(item, dest)

    eprint("Vendor directory created successfully")


def main():
    if len(sys.argv) < 3:
        eprint("Usage:")
        eprint("  fetch-lux-deps-util create-vendor-staging <lock-file> <output-dir>")
        eprint("  fetch-lux-deps-util create-vendor <staging-dir> <output-dir>")
        sys.exit(1)

    command = sys.argv[1]

    if command == 'create-vendor-staging':
        lock_file = Path(sys.argv[2])
        output_dir = Path(sys.argv[3])
        create_vendor_staging(lock_file, output_dir)
    elif command == 'create-vendor':
        staging_dir = Path(sys.argv[2])
        output_dir = Path(sys.argv[3])
        create_vendor(staging_dir, output_dir)
    else:
        eprint(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == '__main__':
    main()

