{ lib, python3Packages }:
with python3Packages;
(toPythonApplication vllm).overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru or { } // {
      services.default = {
        imports = [ (lib.modules.importApply ./service.nix { }) ];
        vllm.package = finalAttrs.finalPackage;
      };
    };
  }
)
