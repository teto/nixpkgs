# fetchLuxDeps

`fetchLuxDeps` is a function for fetching Lua dependencies from a `lux.lock` file, similar to how `fetchCargoVendor` works for Rust/Cargo dependencies.

## Overview

Lux is a modern package manager for Lua that is compatible with luarocks.org and the Rockspec specification. The `fetchLuxDeps` function parses a `lux.lock` file and fetches all dependencies into a vendor directory that Lux expects.

## Usage

`fetchLuxDeps` is typically used as part of `buildLuxPackage`, but can also be used standalone:

```nix
{ fetchLuxDeps, ... }:

let
  luxDeps = fetchLuxDeps {
    # Name for the dependencies derivation
    name = "my-package-deps";
    # or use pname and version
    pname = "my-package";
    version = "1.0.0";

    # Source containing the lux.lock file
    src = ./path/to/source;

    # Hash of the vendored dependencies
    # Use lib.fakeHash initially to get the correct hash
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    # Optional: if lux.lock is in a subdirectory
    luxRoot = "subdir";
  };
in
  # Use luxDeps in your build...
```

## Parameters

- `name` (optional): Name for the dependencies derivation. Defaults to `"${pname}-${version}"` if pname and version are provided, otherwise `"lux-deps"`.
- `pname` (optional): Package name, used to construct the default name.
- `version` (optional): Package version, used to construct the default name.
- `src`: Source directory containing the `lux.lock` file.
- `hash`: Hash of the vendored dependencies. This is a fixed-output derivation, so the hash must be provided. Use `lib.fakeHash` initially to get the correct hash from the error message.
- `luxRoot` (optional): Subdirectory containing the `lux.lock` file, relative to the source root.
- `nativeBuildInputs` (optional): Additional native build inputs.
- Any other parameters supported by `stdenv.mkDerivation` can be passed through.

## Integration with buildLuxPackage

When using `buildLuxPackage`, you can simply provide a `luxHash` parameter:

```nix
{ buildLuxPackage, ... }:

buildLuxPackage {
  pname = "my-lua-package";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "example";
    repo = "my-lua-package";
    rev = "v1.0.0";
    hash = "sha256-...";
  };

  # Hash for the vendored dependencies
  luxHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  # Optional: if lux.lock is in a subdirectory
  luxRoot = "subdir";
}
```

The `buildLuxPackage` function will automatically call `fetchLuxDeps` with the appropriate parameters.

## Lock File Format

The `lux.lock` file is in JSON format with the following structure:

```json
{
  "version": "1.0.0",
  "dependencies": {
    "rocks": {
      "<hash-id>": {
        "name": "package-name",
        "version": "1.0.0-1",
        "source": "luarocks_rockspec+https://luarocks.org/",
        "source_url": {
          "type": "url",
          "url": "https://..."
        },
        "hashes": {
          "rockspec": "sha256-...",
          "source": "sha256-..."
        },
        "dependencies": ["<other-hash-id>", ...]
      }
    },
    "entrypoints": ["<hash-id>", ...]
  },
  "test_dependencies": {
    "rocks": { ... },
    "entrypoints": [...]
  }
}
```

Key features:
- Dependencies are indexed by hash IDs (SHA256 of their metadata)
- Each dependency has a `source_url` field with `type` ("url" or "git") and location
- For git dependencies, `source_url` includes a `ref` field for the commit/tag
- Hashes are provided in base64-encoded SHA256 format (e.g., "sha256-...")
- Both regular and test dependencies are supported

## Dependency Sources

Dependencies can come from multiple sources:

1. **LuaRocks**: Packages from luarocks.org
2. **Git**: Git repositories with a specific revision
3. **Direct URL**: Direct download URLs for archives

## Implementation Details

The `fetchLuxDeps` function uses a two-stage process:

1. **Vendor Staging**: Fetches all dependencies from their sources (LuaRocks, Git, etc.) and creates a staging directory.
2. **Vendor Directory**: Creates the final vendor directory with the correct structure that Lux expects.

This is implemented using:
- `fetch-lux-deps-util.py`: Python script that parses the lock file and fetches dependencies
- `fetch-lux-deps.nix`: Nix function that orchestrates the fetching process

## Troubleshooting

### Getting the correct hash

1. Use `lib.fakeHash` as the initial hash value:
   ```nix
   luxHash = lib.fakeHash;
   ```

2. Run the build. It will fail with an error message containing the correct hash.

3. Replace `lib.fakeHash` with the correct hash from the error message.

### Lock file not found

Make sure the `lux.lock` file exists in your source. If it's in a subdirectory, use the `luxRoot` parameter.

### Dependency fetch failures

Check that:
- Network access is available during the build (this is a fixed-output derivation)
- The URLs in the lock file are correct and accessible
- For Git dependencies, the repository and revision are correct

