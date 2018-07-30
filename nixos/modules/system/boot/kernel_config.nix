# see https://discourse.nixos.org/t/use-lib-types-system-to-merge-attrsets-without-the-module-system/534/7
# here we should fix it: it is expecting
{ lib, config, ... }:

with lib;
  # let
  #   # takes two type functors and return the merged type
  #   expandingMerge = t1: t2:
  #     traceValSeq t1;
  #   in
{

  options = {
    # file = mkOption {
    #   type = types.path;
    #   readOnly = true;
    # };

    fileContents = mkOption {
      readOnly = true;
      # default = "toto";
      type = types.lines;
    };

    settings = mkOption {
      type = (types.attrsOf lib.kernel.kernelItem );
      example = literalExample '' with lib.kernel; {
        "9P_NET" = yes;
        USB = optional yes;
      }'';
      description = ''
        Attribute set
      '';
    };
  };

  config = {

    # TODO convert structured config to string
    # Store the string <replaceable>s</replaceable> in a
# file in the Nix store and return its path
    # file = (builtins.toFile "toto");
# config.fileContents;
    # fileContents = throw "Some function to convert config.params to a string, possibly with some assertions";
    fileContents = kernel.generateNixKConf config.settings null;
  };
}
