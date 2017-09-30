{ stdenv, lua, buildEnv, makeWrapper
, extraLibs ? []
, postBuild ? ""
, ignoreCollisions ? false }:

# Create a python executable that knows about additional packages.
let
  # TODO chech what it does
  # recursivePthLoader = import ../../python-modules/recursive-pth-loader/default.nix { stdenv = stdenv; python = python; };
  env = let
    # I removed recursivePthLoader  but check why
    # closePropagation is in deprecated.nix
    paths = stdenv.lib.closePropagation (extraLibs ++ [  ] ) ;
  in buildEnv {
    name = "${lua.name}-env";

    inherit paths;
    inherit ignoreCollisions;

    # we create wrapper for the binaries in the different packages
    postBuild = ''
      . "${makeWrapper}/nix-support/setup-hook"

      if [ -L "$out/bin" ]; then
          unlink "$out/bin"
      fi
      mkdir -p "$out/bin"

      for path in ${stdenv.lib.concatStringsSep " " paths}; do
        if [ -d "$path/bin" ]; then
          cd "$path/bin"
          for prg in *; do
            if [ -f "$prg" ]; then
              rm -f "$out/bin/$prg"
              if [ -x "$prg" ]; then
                # --set LUA_PATH "$out"
                # todo use --PREFIX instead ?

                makeWrapper "$path/bin/$prg" "$out/bin/$prg" --set "LUA_PATH" "$out" --set "LUA_CPATH" "ZEP"
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

