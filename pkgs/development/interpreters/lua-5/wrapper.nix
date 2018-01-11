{ stdenv, lua, buildEnv, makeWrapper
, extraLibs ? []
, postBuild ? ""
, ignoreCollisions ? false
, lib
, requiredLuaModules
}:

# Create a lua executable that knows about additional packages.
# LUA_PATH should already be built at this point ?!!
let
  env = let
    # I removed recursivePthLoader  but check why
    # closePropagation is in deprecated.nix
    # stdenv.lib.closePropagation
    paths =  requiredLuaModules (extraLibs ++ [ lua ] );
  # here it's supposed to symlink
  in buildEnv {
    name = "${lua.name}-env";

    inherit paths;
    inherit ignoreCollisions;

    # c la qu'on doit avoir un hook no ?
    # we create wrapper for the binaries in the different packages
      # echo "paths=${lib.concatList paths}"
    postBuild = ''
      # LUA_PATH est nul la
      # lib.catAttrs " "

      # si la tu recharges le truc
      . "${makeWrapper}/nix-support/setup-hook"
      # echo "postBuild wrapper"
      # echo "LUA_PATH=$LUA_PATH"
      # echo "LUA_CPATH=$LUA_CPATH"

      if [ -L "$out/bin" ]; then
          unlink "$out/bin"
      fi
      mkdir -p "$out/bin"


      # TODO Fix
      # @luaversion@
      program_LUA_PATH="$out/lib/lua/5.2/?.lua;$out/share/lua/5.2/?.lua;$out/lib/lua/5.2/?/init.lua;$out/share/lua/5.2/?/init.lua"
      program_LUA_CPATH="$out/lib/lua/5.2/?.so;$out/share/lua/5.2/?.so"

      echo "program_LUA_PATH=$program_LUA_PATH"
      echo "program_LUA_CPATH=$program_LUA_CPATH"

      # take every binary from lua packages and put them into the env
      for path in ${stdenv.lib.concatStringsSep " " paths}; do
        echo "looking for binaries in path = $path"
        if [ -d "$path/bin" ]; then
          cd "$path/bin"
          for prg in *; do
            if [ -f "$prg" ]; then
              rm -f "$out/bin/$prg"
              if [ -x "$prg" ]; then
                # --set LUA_PATH "$out"
                # todo use --PREFIX instead ?
                # TODO add itself to LUA_PATH
                echo "generating wrapper for $prg"
      # set -x

                # TODO fix this value is null there
                # --set LUA_PATH "$LUA_PATH" --set LUA_CPATH "ZEP:$LUA_CPATH"
                # use --prefix / suffix LUA_PATH $out/lib/version
                # --suffix LUA_PATH $program_LUA_PATH  ";" --suffix LUA_CPATH $program_LUA_CPATH ";"
                # ENV SEP VAL
                makeWrapper "$path/bin/$prg" "$out/bin/$prg" --suffix LUA_PATH ';' "$program_LUA_PATH"   --suffix LUA_CPATH ';' "$program_LUA_CPATH"
              fi
            fi
          done
        fi
      done
    '' + postBuild;

    # hum check what's the passthru thing
    inherit (lua) meta;

    passthru = lua.passthru // {
      interpreter = "${env}/bin/lua";
      inherit lua;
      env = stdenv.mkDerivation {
        name = "interactive-${lua.name}-environment";
        nativeBuildInputs = [ env ];

        # setupHook = "";

        buildCommand = ''
          echo >&2 ""
          echo >&2 "*** lua 'env' attributes are intended for interactive nix-shell sessions, not for building! ***"
          echo >&2 ""
          exit 1
        '';
    };
    };
  };
in env

