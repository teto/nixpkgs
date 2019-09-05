{ lib, version ? null }:

with lib;
{
  # Common patterns/legacy
  whenAtLeast = ver: mkIf (versionAtLeast version ver);
  whenOlder   = ver: mkIf (versionOlder version ver);
  # range is (inclusive, exclusive)
  whenBetween = verLow: verHigh: mkIf (versionAtLeast version verLow && versionOlder version verHigh);

  /* generate nix intermediate kernel config file of the form
         VIRTIO_MMIO m
         VIRTIO_BLK y
         VIRTIO_CONSOLE n
         NET_9P_VIRTIO? y

   Borrowed from copumpkin https://github.com/NixOS/nixpkgs/pull/12158
   returns a string, expr should be an attribute set
   Use mkValuePreprocess to preprocess option values, aka mark 'modules' as 'yes' or vice-versa
   use the identity if you don't want to override the configured values
  */
  generateNixKConf = exprs:
  let
    mkConfigLine = key: item:
      let
        val = if item.freeform != null then item.freeform else item.tristate;
      in
        if val == null
          then ""
          else if (item.optional)
            then "${key}? ${mkValue val}\n"
            else "${key} ${mkValue val}\n";

    mkConf = cfg: concatStrings (mapAttrsToList mkConfigLine cfg);
  in mkConf exprs;

  mkValue = with lib; val:
  let
    isNumber = c: elem c ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"];

  in
    if (val == "") then "\"\""
    else if val == "y" || val == "m" || val == "n" then val
    else if all isNumber (stringToCharacters val) then val
    else if substring 0 2 val == "0x" then val
    else val; # FIXME: fix quoting one day


  # Keeping these around in case we decide to change this horrible implementation :)
  option = x:
      x // { optional = true; };

  yes      = { tristate    = "y"; };
  no       = { tristate    = "n"; };
  module   = { tristate    = "m"; };
  freeform = x: { freeform = x; };

  isYes = option: {
    assertion = config: config.isYes option;
    message = "CONFIG_${option} is not yes!";
    configLine = "CONFIG_${option}=y";
  };

  isNo = option: {
    assertion = config: config.isNo option;
    message = "CONFIG_${option} is not no!";
    configLine = "CONFIG_${option}=n";
  };

  isModule = option: {
    assertion = config: config.isModule option;
    message = "CONFIG_${option} is not built as a module!";
    configLine = "CONFIG_${option}=m";
  };

  ### Usually you will just want to use these two
  # True if yes or module
  isEnabled = option: {
    assertion = config: config.isEnabled option;
    message = "CONFIG_${option} is not enabled!";
    configLine = "CONFIG_${option}=y";
  };

  # True if no or omitted
  isDisabled = option: {
    assertion = config: config.isDisabled option;
    message = "CONFIG_${option} is not disabled!";
    configLine = "CONFIG_${option}=n";
  };

}
