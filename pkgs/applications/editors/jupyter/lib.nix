{}:
{
  mkHaskellKernel = ghcEnv:
    let
      ghcEnv' = ghcEnv.withPackages (p: [ p.ihaskell ]);
    in

    {
      displayName = "Haskell";
      argv = [
        "${ghcEnv'}/bin/ihaskell"
        "-l"
        # the ihaskell flake does `-l $(${env}/bin/ghc --print-libdir`
        # we guess the path via hardcoded
        # we can't use name else we get the 'with-packages' suffix
        "${ghcEnv}/lib/ghc-${ghcEnv.version}"
        "kernel"
        "{connection_file}"
      ];
      language = "haskell";
      logo32 = null;
      logo64 = null;
    };
}
