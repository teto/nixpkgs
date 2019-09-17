{ lib }:

# TODO do without
with lib;
rec {
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
        val = builtins.trace key (if (item.freeform or null) != null then item.freeform else item.tristate);
      in
        if val == null
          then ""
          else if (item.optional or false)
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
    else if all isNumber (stringToCharacters (builtins.trace val val)) then val
    else if substring 0 2 val == "0x" then val
    else val; # FIXME: fix quoting one day


  /*
    Converts the kernel final configuration file into a structured nix config
    Example:
      loadConfig linux.configfile.outPath
    returns
        { IDE = "y"; ... }
   */
  loadConfig = configFilename: let

    # readLines = builtins.trace "splitting strings" splitString "\n" (builtins.readFile configFilename);
    lines = filter (x: builtins.typeOf x == "string")
        (builtins.split "\n" (builtins.readFile configFilename));

    # lines = [
    #   ''CONFIG_NLS_DEFAULT="utf8"''
    #   ''CONFIG_THREAD_INFO_IN_TASK=y''
    #   ''# CONFIG_LOCALVERSION_AUTO is not set''
    # ];
    parseLine = line:
      let
        # String options have double quotes, e.g. 'CONFIG_NLS_DEFAULT="utf8"' and allow escaping.
        match_freeform = builtins.match ''^CONFIG_([A-Za-z0-9_]+)="(.*)"$'' line;
        match_tristate = builtins.match ''^CONFIG_([A-Za-z0-9_]+)=(.*)$'' line;
        match_unset = builtins.match ''^# CONFIG_([A-Za-z0-9_]+) is not set$'' line;
        match = if (match_freeform != null && (length match_freeform == 2) ) then
          nameValuePair (head match_freeform) (last match_freeform)
        else if (match_tristate != null && (length match_tristate == 2)) then
          nameValuePair (head match_tristate) (last match_tristate)
        else if (match_unset != null) then
          nameValuePair (head match_unset) "n"
        else
          null
        ;

      in
        optional (match != null) match;
    in
      # builtins.trace x
      # (x: lib.traceVal (parseLine x)
      # (lib.traceVal
      listToAttrs (foldr (line: prev: (parseLine line) ++ prev) [] lines );

  # Keeping these around in case we decide to change this horrible implementation :)
  option = x:
      x // { optional = true; };

  yes      = { tristate    = "y"; };
  no       = { tristate    = "n"; };
  module   = { tristate    = "m"; };
  freeform = x: { freeform = x; };

  # the idea here is we use these settings to build a structured config
  isYes = option: {
    assertion = config: config.isYes option;
    message = "CONFIG_${option} is not yes!";
    configLine = "CONFIG_${option}=y";
    structured = { option = yes; };
  };

  isNo = option: {
    assertion = config: config.isNo option;
    message = "CONFIG_${option} is not no!";
    configLine = "CONFIG_${option}=n";
    structured = { option = no; };
  };

  isModule = option: {
    assertion = config: config.isModule option;
    message = "CONFIG_${option} is not built as a module!";
    configLine = "CONFIG_${option}=m";
    structured = { option = module; };
  };

  ### Usually you will just want to use these two
  # True if yes or module
  isEnabled = option: {
    assertion = config: config.isEnabled option;
    message = "CONFIG_${option} is not enabled!";
    configLine = "CONFIG_${option}=y";
    structured = { option = yes; };
  };

  # True if no or omitted
  isDisabled = option: {
    assertion = config: config.isDisabled option;
    message = "CONFIG_${option} is not disabled!";
    configLine = "CONFIG_${option}=n";
    structured = { option = no; };
  };

}
