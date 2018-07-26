{ lib
# we pass the kernel version here to keep a nice syntax `whenOlder "4.13"`
# kernelVersion, e.g., config.boot.kernelPackages.version
# , version ? null
, mkValuePreprocess ? null
}:

with lib;
rec {
  # mergeAsModule / mergeAsNo / mergeAsYes
  # winOrder is a list [ "y" "m" "n"]
  findWinner = candidates: winner:
    any winner candidates;

  mergeAnswer = winners: loc: defs:
    let
      values = map (x: x.value) defs;
      # any/count/partition
      # hasNo = any (x: x == "n") values;
      # hasPositive = any (x: x == "m" || x == "y") values;
      # groups = partition (x: x == "n") values;
      # differentAnswers = unique map (x: x.value) defs;
      inter = intersectLists values winOrder;
      winner = head winners;
      # winner = any
    in
    if defs == [] then abort "This case should never happen."
    else if winner == [] then abort "Give a valid list of winner"
    else if findWinner values winner then
      winner
    else
      mergeAnswer (tail winners) locs defs;

    # else
    # throw "The unique option `${showOption loc}' is defined multiple times, in ${showFiles (getFiles defs)}."
    # else (head inter).value;

  kernelItem = types.submodule {
# visible = false;
    # merge function defined in mkOption
    # merge = x: "toto";
    options = {
      answer = mkOption {
        type = types.str // {
        # mergeOneOption
        # traceValSeqFn (x: "answer ${x}")
        # merge = locs: defs: builtins.trace "test" mergeOneOption locs defs;
        merge = locs: defs: builtins.trace "test" mergeAnswer [ "y" "m" "n" ] locs defs;

        };
        default = null;
        # internal = true;
        # visible = true;
        description = ''
          For most options "y" or "m" or "n" but freeform.
        '';
      };

      optional = mkOption {
        type = types.bool;
        default = false;
        # internal = true;
        description = ''
          Wether it should fail if not asked.
        '';
      };
    };
  } // {

    # merge
    # merge = f1: f2: builtins.trace "merge" expandingMerge ;
    # typeMerge = f1: f2: builtins.trace "typeMerge" expandingMerge ;
  };

  # Common patterns
  # TODO asset when version is not available ?
  # when        = cond: opt: if cond then opt else null;
  when        = cond: opt: if cond then opt else null;
  # whenAtLeast = ver: when (versionAtLeast version ver);
  # whenOlder   = ver: when (versionOlder version ver);
  # whenBetween = verLow: verHigh: when (versionAtLeast version verLow && versionOlder version verHigh);


   # Merge a list of definitions together into a single value.
      # This function is called with two arguments: the location of
      # the option in the configuration as a list of strings
      # (e.g. ["boot" "loader "grub" "enable"]), and a list of
      # definition values and locations (e.g. [ { file = "/foo.nix";
      # value = 1; } { file = "/bar.nix"; value = 2 } ]).


  # Keeping these around in case we decide to change this horrible implementation :)
  option = x:
    # look at mergeDefinitions / mergedValue
    # dischargeProperties /
    # mkIf for features
    # evalOptionValue
     # 'loc' is the list of attribute names where the option is located.
     # 'opts' is a list of modules.  Each module has an options attribute which
    traceValSeq (
      # merge = loc: defs:
      # look at mergeEqualOption to see how it's done
      # kernelItem.merge [] [ { file= "toto"; value = x;} { file="toto"; value = { optional = true; }; } ]
      x // { optional = true; }
    );

  yes    = { answer = "y"; };
  no     = { answer = "n"; };
  module = { answer = "m"; };

  # convert into attrSet if doesn't exist
  configItemAsAttr = item:
    if builtins.isAttrs item then item else { answer = item; optional = false; };

  # might want to copy/move from kernel.nix the isEnabled/isYes etc
  # mergeConfigItem = config1: config2:
  # let
  #   c1 = builtins.trace "c1" (traceValSeq (configItemAsAttr config1));
  #   c2 = builtins.trace "c2" (traceValSeq (configItemAsAttr config2));
  # in
  #   builtins.trace "merged config:" (traceValSeq {
  #     # builtins.isAttrs
  #     # TODO merge conditions too
  #     optional = (c1 ? optional) && (c2 ? optional);
  #     # for now take c2 answer
  #     # answer   =  (if (c2.answer != null) then c2.answer else c1.answer);
  #     answer   =  (c2.answer or c1.answer);
  #   });

  mkValue = val:
  let
    isNumber = c: elem c ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"];

  in
    if (builtins.trace val (val == "")) then "\"\""
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
        # val_temp = builtins.trace key rawval;
        # val = if builtins.isAttrs val_temp then val_temp.answer else val_temp;
        item = builtins.trace key (configItemAsAttr rawval);
        val = item.answer;
      in
        if val == null
          then ""
          else if (val ? optional)
            then "${key}? ${mkValue val}\n"
            else "${key} ${mkValue val}\n";

    mkConf = cfg: concatStrings (mapAttrsToList mkConfigLine cfg);
  in mkConf exprs;

  # overrideExisting
  # mergeStructuredConf = c1: c2:
  #   # c2 params should override c1 ones
  #   # lib.recursiveUpdate c1 c2;

  #   # foldAttrs
  #      # foldAttrs (n: a: [n] ++ a) [] [{ a = 2; } { a = 3; }]
  #      # => { a = [ 2 3 ]; }
  #   lib.foldAttrs mergeConfigItem {} [c1 c2];

}
