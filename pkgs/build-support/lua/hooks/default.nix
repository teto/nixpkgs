{
  stdenv,
  diffutils,
  lib,
  makeSetupHook,
  rust,
  pkgsTargetTarget,
  lua,

  ...

}:
{
  luxBuildHook = makeSetupHook {
    name = "lux-build-hook.sh";
    substitutions = {
      # inherit (stdenv.targetPlatform.rust) rustcTarget;
      # what are those ?
      inherit (lua) luaversion;
      inherit (rust.envVars) setEnv;

    };
    # passthru.tests = {
    #   # test = tests.rust-hooks.luxBuildHook;
    # }
    # // lib.optionalAttrs (stdenv.isLinux) {
    #   testCross = pkgsCross.riscv64.tests.rust-hooks.luxBuildHook;
    # };
  } ./lux-build-hook.sh;

  luxCheckHook = makeSetupHook {
    name = "lux-check-hook.sh";
    substitutions = {
      # inherit (stdenv.targetPlatform.rust) rustcTarget;
      inherit (rust.envVars) setEnv;
    };
  } ./lux-check-hook.sh;

  luxInstallHook = makeSetupHook {
    name = "lux-install-hook.sh";
    substitutions = {
      # targetSubdirectory = target;
    };
  } ./lux-install-hook.sh;

  # luxNextestHook = makeSetupHook {
  #   name = "lux-nextest-hook.sh";
  #   propagatedBuildInputs = [ lux-nextest ];
  #   substitutions = {
  #     # inherit (stdenv.targetPlatform.rust) rustcTarget;
  #   };
  # } ./lux-nextest-hook.sh;

  luxSetupHook = makeSetupHook {
    name = "lux-setup-hook.sh";
    propagatedBuildInputs = [ ];
    substitutions = {
      # defaultConfig = ../fetchlux-default-config.toml;

      # Specify the stdenv's `diff` by abspath to ensure that the user's build
      # inputs do not cause us to find the wrong `diff`.
      diff = "${lib.getBin diffutils}/bin/diff";

      # luxConfig =
      #   lib.optionalString (stdenv.hostPlatform.config != stdenv.targetPlatform.config) ''
      #     [target."${stdenv.targetPlatform.rust.rustcTarget}"]
      #     "linker" = "${pkgsTargetTarget.stdenv.cc}/bin/${pkgsTargetTarget.stdenv.cc.targetPrefix}cc"
      #     "rustflags" = [ ${
      #       lib.concatStringsSep ", " (
      #         [
      #           ''"-Ctarget-feature=${if stdenv.targetPlatform.isStatic then "+" else "-"}crt-static"''
      #         ]
      #         ++ lib.optional (!stdenv.targetPlatform.isx86_32) ''"-Cforce-frame-pointers=yes"''
      #       )
      #     } ]
      #   ''
      #   + ''
      #     [target."${stdenv.hostPlatform.rust.rustcTarget}"]
      #     "linker" = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
      #     "rustflags" = [ ${
      #       lib.optionalString (!stdenv.hostPlatform.isx86_32) ''"-Cforce-frame-pointers=yes"''
      #     } ]
      #   '';
    };

  } ./lux-setup-hook.sh;

}

