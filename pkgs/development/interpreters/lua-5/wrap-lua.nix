{ lib
, lua
, makeSetupHook
, makeWrapper }:

with lib;



# defined in trivial-builders.nix
# imported as wrapLua in lua-packages.nix and pased to mk-lua-derivation to be used as buildInput
makeSetupHook {
      deps = makeWrapper;
      # substitutions.libPrefix = lua.libPrefix;
      # look for python it's the interpreter generated in the env
      # substitutions.executable = "${env}/bin/${lua}";
      substitutions.executable = lua.interpreter;
      substitutions.lua = lua;
      substitutions.luaversion = lua.majorVersion;


      # all the following is magicalSedExpression
      # substitutions.magicalSedExpression = let
      substitutions.magicalSedExpressionBAckup = let
        # Looks weird? Of course, it's between single quoted shell strings.
        # NOTE: Order DOES matter here, so single character quotes need to be
        #       at the last position.
        quoteVariants = [ "'\"'''\"'" "\"\"\"" "\"" "'\"'\"'" ]; # hey Vim: ''

        mkStringSkipper = labelNum: quote: let
          label = "q${toString labelNum}";
          isSingle = elem quote [ "\"" "'\"'\"'" ];
          endQuote = if isSingle then "[^\\\\]${quote}" else quote;
        in ''
          /^[a-z]?${quote}/ {
            /${quote}${quote}|${quote}.*${endQuote}/{n;br}
            :${label}; n; /^${quote}/{n;br}; /${endQuote}/{n;br}; b${label}
          }
        '';

        # This preamble does two things:
        # * Sets argv[0] to the original application's name; otherwise it would be .foo-wrapped.
        # * Adds all required libraries to sys.path via `site.addsitedir`. It also handles *.pth files.
        preamble = ''
          sys.argv[0] = '"'$(readlink -f "$f")'"'
          export LUA_PATH="$program_LUA_PATH"
          export LUA_CPATH="$program_LUA_CPATH"
          functools.reduce(lambda k, p: site.addsitedir(p, k), ['"$([ -n "$program_PYTHONPATH" ] && (echo "'$program_PYTHONPATH'" | sed "s|:|','|g") || true)"'], site._init_pathinfo())
        '';

      in ''
        1 {
          :r
          /\\$|,$/{N;br}
          /__future__|^ |^ *(#.*)?$/{n;br}
          ${concatImapStrings mkStringSkipper quoteVariants}
          /^[^# ]/i ${replaceStrings ["\n"] [";"] preamble}
        }
      '';
} ./wrap.sh

