{ lib
# we pass the kernel version here to keep a nice syntax `whenOlder "4.13"`
# kernelVersion, e.g., config.boot.kernelPackages.version
# , version ? null
, mkValuePreprocess ? null
}:

with lib;
rec {
  # Common patterns
  # TODO asset when version is not available ?
  when        = cond: opt: if cond then opt else null;
  whenAtLeast = ver: when (versionAtLeast version ver);
  whenOlder   = ver: when (versionOlder version ver);
  whenBetween = verLow: verHigh: when (versionAtLeast version verLow && versionOlder version verHigh);

  # Keeping these around in case we decide to change this horrible implementation :)
  option = x:
    # if x == null then null else "?${x}";
      x // { optional = true; };
  yes    = { answer = "y"; };
  no     = { answer = "n"; };
  module = { answer = "m"; };

  # might want to copy/move from kernel.nix the isEnabled/isYes etc
  mergeConfigItem = c1: c2:
    {
      optional = (c1 ? optional) && (c2 ? optional);
      answer   = c2.answer;
    };

  mkValue = val:
  let
    isNumber = c: elem c ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"];
  in
    if val == "" then "\"\""
    else if val == "y" || val == "m" || val == "n" then val
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
        # val = if builtins.isFunction mkValuePreprocess then mkValuePreprocess rawval else rawval;
        val = builtins.trace key rawval;
      in
        if val == null
          then ""
          else if (val ? optional)
            then "${key}? ${mkValue val.answer}\n"
            else "${key} ${mkValue val.answer}\n";

    mkConf = cfg: concatStrings (mapAttrsToList mkConfigLine cfg);
  in mkConf exprs;

  # overrideExisting
  mergeStructuredConf = c1: c2:
    # c2 params should override c1 ones
    # lib.recursiveUpdate c1 c2;

    # foldAttrs
       # foldAttrs (n: a: [n] ++ a) [] [{ a = 2; } { a = 3; }]
       # => { a = [ 2 3 ]; }
    lib.foldAttrs mergeConfigItem [] [c1 c2];

}
