{
  lib,
  stdenvNoCC,
  runCommand,
  writers,
  python3Packages,
  lux-cli,
  nix-prefetch-git,
  cacert,
  git,
}:

let
  fetchLuxDepsUtil = writers.writePython3Bin "fetch-lux-deps-util" {
    libraries =
      with python3Packages;
      [
        requests
      ]
      ++ requests.optional-dependencies.socks; # to support socks proxy envs like ALL_PROXY in requests
    flakeIgnore = [
      "E128"
      "E501"
    ];
  } (builtins.readFile ./lua/fetch-lux-deps-util.py);
in

{
  name ? if args ? pname && args ? version then "${args.pname}-${args.version}" else "lux-deps",
  hash ? (throw "fetchLuxDeps requires a `hash` value to be set for ${name}"),
  nativeBuildInputs ? [ ],
  ...
}@args:

# TODO: add asserts about pname version and name

let
  removedArgs = [
    "name"
    "pname"
    "version"
    "nativeBuildInputs"
    "hash"
  ];

  vendorStaging = stdenvNoCC.mkDerivation (
    {
      name = "${name}-vendor-staging";

      impureEnvVars = lib.fetchers.proxyImpureEnvVars;

      nativeBuildInputs = [
        fetchLuxDepsUtil
        cacert
        git
        # break loop: nix-prefetch-git -> git-lfs -> ...
        # Lux may use git dependencies
        (nix-prefetch-git.override { git-lfs = null; })
      ]
      ++ nativeBuildInputs;

      buildPhase = ''
        runHook preBuild

        if [ -n "''${luxRoot-}" ]; then
          cd "$luxRoot"
        fi

        # Find the lux.lock file
        if [ -f lux.lock ]; then
          LOCK_FILE="lux.lock"
        elif [ -f Lux.lock ]; then
          LOCK_FILE="Lux.lock"
        else
          echo "Error: No lux.lock file found"
          exit 1
        fi

        fetch-lux-deps-util create-vendor-staging "$LOCK_FILE" "$out"

        runHook postBuild
      '';

      strictDeps = true;

      dontConfigure = true;
      dontInstall = true;
      dontFixup = true;

      outputHash = hash;
      outputHashAlgo = if hash == "" then "sha256" else null;
      outputHashMode = "recursive";
    }
    // removeAttrs args removedArgs
  );
in

runCommand "${name}-vendor"
  {
    inherit vendorStaging;
    nativeBuildInputs = [
      fetchLuxDepsUtil
      lux-cli
    ];
  }
  ''
    fetch-lux-deps-util create-vendor "$vendorStaging" "$out"
  ''
