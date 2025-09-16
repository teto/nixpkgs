# fetchLuxDeps Implementation - Summary of Changes

## Overview
Updated the `fetchLuxDeps` implementation to work with the actual Lux lock file format.

## Key Changes

### 1. Updated Python Utility Script (`pkgs/build-support/lua/fetch-lux-deps-util.py`)

#### Lock File Parsing
- **Changed**: Now parses the actual Lux lock file format which uses hash-based dependency keys
- **Structure**: Dependencies are stored under `dependencies.rocks` and `test_dependencies.rocks`
- **Hash IDs**: Each dependency is indexed by a SHA256 hash of its metadata
- **Format**: JSON only (removed TOML support as Lux uses JSON)

#### Dependency Information Extraction
The parser now extracts:
- `hash_id`: The unique hash identifier for the dependency
- `name`: Package name (e.g., "mega.logging")
- `version`: Version string (e.g., "1.1.6-1")
- `source_type`: Either "url" or "git" from `source_url.type`
- `source_url`: The download URL from `source_url.url`
- `source_ref`: Git reference (commit/tag) for git dependencies from `source_url.ref`
- `expected_hash`: SHA256 hash from `hashes.source` for verification

#### Source Types Supported
1. **URL sources**: Direct downloads of archives (.zip, .tar.gz, etc.)
   ```json
   "source_url": {
     "type": "url",
     "url": "https://github.com/user/repo/archive/v1.0.zip"
   }
   ```

2. **Git sources**: Git repositories with specific refs
   ```json
   "source_url": {
     "type": "git",
     "url": "https://github.com/user/repo.git",
     "ref": "v1.0.0"
   }
   ```

#### Hash Verification
- Implements SHA256 hash verification for downloaded files
- Converts base64-encoded hashes (format: "sha256-...") to hex for comparison
- Warns on hash mismatches but continues processing

#### Archive Extraction
- Improved archive extraction to handle nested directory structures
- Automatically detects if archive has a single top-level directory
- Supports .zip, .tar.gz, .tgz, and .tar formats

#### Git Cloning
- Uses `nix-prefetch-git` when available for better Nix integration
- Falls back to regular `git clone` if nix-prefetch-git fails
- Handles both branch/tag names and commit hashes
- Removes .git directory after cloning to save space

#### Error Handling
- More robust error handling with timeouts for network operations
- Continues processing other dependencies if one fails
- Detailed error messages for debugging

### 2. Documentation Updates (`pkgs/build-support/fetch-lux-deps-README.md`)

Updated the lock file format documentation to reflect the actual structure:
- Hash-based dependency indexing
- Nested structure under `dependencies.rocks`
- Separate sections for regular and test dependencies
- Entrypoints arrays for top-level dependencies

## Example Lux Lock File Structure

```json
{
  "version": "1.0.0",
  "dependencies": {
    "rocks": {
      "392c069ca7154cb446b52b0f9c6be33de04e6a6f0a7c9ff762b30c5b9db1bdc7": {
        "name": "mega.logging",
        "version": "1.1.6-1",
        "source_url": {
          "type": "url",
          "url": "https://github.com/ColinKennedy/mega.logging/archive/v1.1.6.zip"
        },
        "hashes": {
          "rockspec": "sha256-b/UNBHzASov3C1Tp3B43NfCtejHOBc3FjYNZHAndRu0=",
          "source": "sha256-xz8Btm9bYc+VR5jcgdzVSmnhFaVzi7pj6NkoBXd0FFQ="
        }
      }
    },
    "entrypoints": ["392c069ca..."]
  }
}
```

## Vendor Directory Structure

The script creates a vendor directory with the following structure:
```
vendor/
├── package-name1/
│   └── version1/
│       └── (package contents)
├── package-name2/
│   └── version2/
│       └── (package contents)
└── ...
```

## Testing Recommendations

1. Test with a real Lux project that has a lux.lock file
2. Verify hash computation and verification works correctly
3. Test both URL and git source types
4. Test with packages that have nested archive directories
5. Verify the vendor directory structure matches Lux expectations

## Known Limitations

1. Currently processes dependencies sequentially (not in parallel) to avoid overwhelming git operations
2. Hash verification uses base64-encoded SHA256; other formats may need additional support
3. Assumes standard archive formats (.zip, .tar.gz, etc.)

## Future Improvements

1. Add support for parallel fetching with rate limiting
2. Implement caching to avoid re-downloading dependencies
3. Add more detailed progress reporting
4. Support additional archive formats if needed
5. Add validation of the final vendor directory structure

