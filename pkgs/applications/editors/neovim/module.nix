{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {
    withPython3 = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Python 3 provider.";
    };

    withNodeJs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Node provider.";
    };

  };

}
