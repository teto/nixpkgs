{ lib
# we pass the kernel version here to keep a nice syntax `whenOlder "4.13"`
# kernelVersion, e.g., config.boot.kernelPackages.version
, version
, mkValuePreprocess ? null
}:

with lib;
rec {

  kernelItem = types.submodule {
    options = {
      answer = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable TLS/SSL.
        '';
      };

      optional = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Wether it should fail if not asked.
        '';
      };

      # conditions
      # certificatesFile = mkOption {
      #   type = types.nullOr types.path;
      #   default = null;
      #   description = ''
      #     Path to file containing certificate authorities that should
      #     be used to validate the connection authenticity. If
      #     <literal>null</literal> then the system default is used.
      #     Note, if set then the system default may still be accepted.
      #   '';
      # };
    };
  };

  # Common patterns
  when        = cond: opt: if cond then opt else null;
  whenAtLeast = ver: when (versionAtLeast version ver);
  whenOlder   = ver: when (versionOlder version ver);
  whenBetween = verLow: verHigh: when (versionAtLeast version verLow && versionOlder version verHigh);

  # Keeping these around in case we decide to change this horrible implementation :)
  option = x: if x == null then null else "?${x}";
  yes    = "y";
  no     = "n";
  module = "m";

  mkValue = val:
  let
    isNumber = c: elem c ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"];
  in
    if val == "" then "\"\""
    else if val == yes || val == module || val == no then val
    else if all isNumber (stringToCharacters val) then val
    else if substring 0 2 val == "0x" then val
    else val; # FIXME: fix quoting one day


  # generate nix intermediate kernel config file of the form
  #
  #       VIRTIO_MMIO m
  #       VIRTIO_BLK y
  #       VIRTIO_CONSOLE n
  #       NET_9P_VIRTIO? y
  #
  # Use mkValuePreprocess to preprocess option values, aka mark 'modules' as
  # 'yes' or vice-versa
  # Borrowed from copumpkin https://github.com/NixOS/nixpkgs/pull/12158
  # returns a string, expr should be an attribute set
  generateNixKConf = exprs: mkValuePreprocess:
  let
    mkConfigLine = key: rawval:
    let
      val = if builtins.isFunction mkValuePreprocess then mkValuePreprocess rawval else rawval;
    in
      if val == null
        then ""
        else if hasPrefix "?" val
          then "${key}? ${mkValue (removePrefix "?" val)}\n"
          else "${key} ${mkValue val}\n";
    mkConf = cfg: concatStrings (mapAttrsToList mkConfigLine cfg);
  in mkConf exprs;
}
