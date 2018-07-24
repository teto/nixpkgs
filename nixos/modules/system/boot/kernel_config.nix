# see https://discourse.nixos.org/t/use-lib-types-system-to-merge-attrsets-without-the-module-system/534/7
# here we should fix it: it is expecting
{ lib, config, ... }:

with lib;
{

  options = {
    file = mkOption {
      type = types.path;
    };
    fileContents = mkOption {
      readOnly = true;
      type = types.lines;
    };

    # list of
    params = mkOption {
      type = types.attrsOf lib.kernel.kernelItem;
    };
  };

  config = {

    # TODO convert structured config to string
    file = builtins.toFile "toto";
      # config.fileContents;
    fileContents = throw "Some function to convert config.params to a string, possibly with some assertions";
  };
}
