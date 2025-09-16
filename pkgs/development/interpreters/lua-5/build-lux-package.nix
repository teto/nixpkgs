{
  lib,
  # importluxLock,
  stdenv,
  luxBuildHook,
  pkg-config,
  # luxCheckHook,
  # luxInstallHook,
  # luxNextestHook,
  # luxSetupHook,
  # lux-auditable,
  # buildPackages,
  lux-cli,
  lua,
  fetchLuxDeps,

  which,
  strace,

}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "depsExtraArgs"
    "luxUpdateHook"
    "luxLock"
    "useFetchluxVendor"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      name ? "${args.pname}-${args.version}",

      # Name for the vendored dependencies tarball
      luxDepsName ? name,

      src ? null,
      srcs ? null,
      preUnpack ? null,
      unpackPhase ? null,
      postUnpack ? null,
      luxPatches ? [ ],
      patches ? [ ],
      sourceRoot ? null,
      luxRoot ? null,
      logLevel ? "",
      buildInputs ? [ ],
      nativeBuildInputs ? [ ],
      luxUpdateHook ? "",
      luxDepsHook ? "",
      buildType ? "release",
      meta ? { },
      useFetchluxVendor ? true,
      luxDeps ? null,
      luxLock ? null,
      luxVendorDir ? null,
      checkType ? buildType,
      buildNoDefaultFeatures ? false,
      checkNoDefaultFeatures ? buildNoDefaultFeatures,
      buildFeatures ? [ ],
      checkFeatures ? buildFeatures,
      useNextest ? false,

      depsExtraArgs ? { },

      # Needed to `pushd`/`popd` into a subdir of a tarball if this subdir
      # contains a lux.toml, but isn't part of a workspace (which is e.g. the
      # case for `rustfmt`/etc from the `rust-sources).
      # Otherwise, everything from the tarball would've been built/tested.
      buildAndTestSubdir ? null,
      ...
    }@args:

    # lib.optionalAttrs (stdenv.hostPlatform.isDarwin && buildType == "debug") {
    #   RUSTFLAGS = "-C split-debuginfo=packed " + (args.RUSTFLAGS or "");
    # }
    # //
    {
      luxDeps =
        if luxVendorDir != null then
          null
        else if luxDeps != null then
          luxDeps
        else if luxLock != null then
          throw "importluxLock is not yet implemented, use luxHash instead"
        else if args.luxHash or null == null then
          null # No dependencies to fetch
        else
          fetchLuxDeps (
            {
              inherit
                src
                srcs
                sourceRoot
                luxRoot
                preUnpack
                unpackPhase
                postUnpack
                ;
              name = luxDepsName;
              patches = luxPatches;
              hash = args.luxHash;
            }
            // depsExtraArgs
          );
      # inherit buildAndTestSubdir;

      nativeBuildInputs = nativeBuildInputs ++ [
        which
        pkg-config # to find lua
        lua
        strace
        lua.pkgs.lux-lua
        luxBuildHook
        # luxInstallHook
        # luxSetupHook
        # lux-cli should be able to find the lua instance regardless of its own lua version
        lux-cli
      ];

      buildInputs = buildInputs ++ [
        which
        pkg-config # to find lua
        lua
        strace
        lua.pkgs.lux-lua
      ]

      ;

      # patches = luxPatches ++ patches;

      configurePhase =
        args.configurePhase or ''
          runHook preConfigure
          runHook postConfigure
        '';

      doCheck = args.doCheck or true;

      # strictDeps = true;

      meta = meta // {
        badPlatforms = meta.badPlatforms or [ ];
        # default to Rust's platforms
        platforms = lib.intersectLists meta.platforms or lib.platforms.all lux-cli.meta.platforms;
      };
    };
}
