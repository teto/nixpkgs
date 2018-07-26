# see https://discourse.nixos.org/t/use-lib-types-system-to-merge-attrsets-without-the-module-system/534/7
# here we should fix it: it is expecting
{ lib, config, ... }:

with lib;
  let
    # takes two type functors and return the merged type
    expandingMerge = t1: t2:
      traceValSeq t1;
    # mkOptionType
    in
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

    # list of
    params = mkOption {
      # merge is here to
      # merge =
      # defaultTypeMerge
      # A function to merge multiple type declarations. Takes the type to merge
      # <literal>functor</literal> as parameter. A <literal>null</literal> return
      # value means that type cannot be merged.
      # typeMerge = builtins.trace "typeMerge" expandingMerge ;
      type = (types.attrsOf lib.kernel.kernelItem )
      # // {
      #   typeMerge = builtins.trace "typeMerge" expandingMerge ;
      #   merge = builtins.trace "Uerge" expandingMerge ;
      # }
    ;
    };
  };

  config = {

    # TODO convert structured config to string
    # Store the string <replaceable>s</replaceable> in a
# file in the Nix store and return its path
    # file = (builtins.toFile "toto");
# config.fileContents;
    # fileContents = throw "Some function to convert config.params to a string, possibly with some assertions";
    fileContents = kernel.generateNixKConf config.params null;
  };
}
