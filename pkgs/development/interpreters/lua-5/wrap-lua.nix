{ lib
, lua
, makeSetupHook
, makeWrapper }:

with lib;



# defined in trivial-builders.nix
# makeSetupHook = { deps ? [], substitutions ? {} }: script:
makeSetupHook {
      deps = makeWrapper;
      # substitutions.libPrefix = lua.libPrefix;
      # look for python it's the interpreter generated in the env
      # substitutions.executable = "bin/lua";
      # substitutions.executable = "${env}/bin/${lua}";
      substitutions.executable = lua.interpreter;
      substitutions.lua = lua;
      substitutions.luaversion = "5.2"; # lua.version;
      # substitutions.magicalSedExpression = let
      #   # Looks weird? Of course, it's between single quoted shell strings.
      #   # NOTE: Order DOES matter here, so single character quotes need to be
      #   #       at the last position.
      #   quoteVariants = [ "'\"'''\"'" "\"\"\"" "\"" "'\"'\"'" ]; # hey Vim: ''

      #   mkStringSkipper = labelNum: quote: let
      #     label = "q${toString labelNum}";
      #     isSingle = elem quote [ "\"" "'\"'\"'" ];
      #     endQuote = if isSingle then "[^\\\\]${quote}" else quote;
      #   in ''
      #     /^[a-z]?${quote}/ {
      #       /${quote}${quote}|${quote}.*${endQuote}/{n;br}
      #       :${label}; n; /^${quote}/{n;br}; /${endQuote}/{n;br}; b${label}
      #     }
      #   '';

        # This preamble does two things:
        # * Sets argv[0] to the original application's name; otherwise it would be .foo-wrapped.
        #   Python doesn't support `exec -a`.
        # * Adds all required libraries to sys.path via `site.addsitedir`. It also handles *.pth files.
        # preamble = ''
        #   import sys
        #   import site
        #   import functools
        #   sys.argv[0] = '"'$(readlink -f "$f")'"'
        #   functools.reduce(lambda k, p: site.addsitedir(p, k), ['"$([ -n "$program_PYTHONPATH" ] && (echo "'$program_PYTHONPATH'" | sed "s|:|','|g") || true)"'], site._init_pathinfo())
        # '';

      # in ''
        # 1 {
        #   :r
        #   /\\$|,$/{N;br}
        #   /__future__|^ |^ *(#.*)?$/{n;br}
        #   ${concatImapStrings mkStringSkipper quoteVariants}
        #   /^[^# ]/i ${replaceStrings ["\n"] [";"] preamble}
        # }
      # '';
} ./wrap.sh

