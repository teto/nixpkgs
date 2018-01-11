# Generic builder for lua packages

{ lib
, lua
, luarocks
, stdenv
, wrapLua
, unzip
, writeText

# Whether the derivation provides a Python module or not.
, toLuaModule

# adds a postUnpackHooks (can we discard ?)
, ensureNewerSourcesHook
}:

{
name ? "${attrs.pname}-${attrs.version}"

, version
# by default prefix `name` e.g. "python3.3-${name}"
, namePrefix ? lua.name + "-"

# Dependencies for building the package
, buildInputs ? [  ]

# Dependencies needed for running the checkPhase.
# These are added to buildInputs when doCheck = true.
, checkInputs ? []

# propagate build dependencies so in case we have A -> B -> C,
# C can import package A propagated by B
, propagatedBuildInputs ? []
, propagatedNativeBuildInputs ? []

# DEPRECATED: use propagatedBuildInputs
# , pythonPath ? []

# used to disable derivation, useful for specific python versions
, disabled ? false

# Raise an error if two packages are installed with the same name
, catchConflicts ? false

# Additional arguments to pass to the makeWrapper function, which wraps
# generated binaries.
, makeWrapperArgs ? []

# Skip wrapping of lua programs altogether
, dontWrapLuaPrograms ? false

, meta ? {}

, passthru ? {}
, doCheck ? false
, preShellHook ? ""
, postShellHook ? ""

, ... } @ attrs:


# Keep extra attributes from `attrs`, e.g., `patchPhase', etc.
if disabled
# .executable
then throw "${name} not supported for interpreter ${lua}"
else

let

  # todo use this
  # Used to be $PWD
  luarocks_config = writeText "luarocksConfig" ''
    local_cache = ""
    '';
in

# python now does:
# toPythonModule (python.stdenv.mkDerivation (builtins.removeAttrs attrs [
#     "disabled" "checkInputs" "doCheck" "doInstallCheck" "dontWrapPythonPrograms" "catchConflicts"
#   ] // {
toLuaModule ( lua.stdenv.mkDerivation (
builtins.removeAttrs attrs ["disabled" "checkInputs"] // {

  name = namePrefix + name;


  buildInputs = [ wrapLua luarocks ]
    # ++ [ (ensureNewerSourcesHook { year = "1980"; }) ]
    ++ buildInputs
    # might get rid of ?
    ++ lib.optionals doCheck checkInputs
    ;

  # propagate python/setuptools to active setup-hook in nix-shell
  # propagatedBuildInputs = propagatedBuildInputs ++ [ lua ];
  propagatedBuildInputs = propagatedBuildInputs ++ [ lua ];
  # Python packages don't have a checkPhase, only an installCheckPhase
  doCheck = false;
  doInstallCheck = doCheck;


  # luarocks_cfg = "$(pwd)/luarocks_cfg";
  #   '';
  # LUAROCKS_CONFIG="${luarocks_cfg}";
  #   output=$(luarocks unpack --verbose --force "$renamed")
  #   '';

  # that works only for src.rock !
  # stripVersion
  setSourceRoot= let
    name_only=(builtins.parseDrvName name).name;
    in ''
    folder=$(find . -mindepth 2 -maxdepth 2 -type d -path '*${name_only}*'|head -n1)
    echo "folder found ='$folder'"
    sourceRoot=$folder
  '';

  # TODO fix hooks, run them etc..
  # preBuild
  buildPhase = ''
    runHook preBuild
    echo "we are in folder $PWD"
    export LUAROCKS_CONFIG="$PWD/luarocks_cfg"
    echo "local_cache = '$PWD'" > "$LUAROCKS_CONFIG"
  '';


  # even here we should export LUA_PATH ?
  postFixup = lib.optionalString (!dontWrapLuaPrograms) ''
    wrapLuaPrograms
  '' + attrs.postFixup or '''';

    # export PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH"

  # posthook run for the current derivation only
  # postHook = ''
  #   # function addLuaPath() {
  #   echo "running the hook dude"
  #   folder="$out/lib/lua/${lua.libFolder}"
  #         export LUA_PATH="$folder:$LUA_PATH"
  #         export LUA_CPATH="$folder:$LUA_CPATH"
  #     # }
  #   # envHooks+=(addLuaPath)
  #   '';
  # TODO maybe we can remove the unpackPhase as it will be redownloaded


  # inspired from build-python-setup-tools
  shellHook = attrs.shellHook or ''
    ${preShellHook}
      echo "SHELL HOOK from lua-mk-derivation"
      export MATTATOR="HELLO WORLD"
    # export LUA_PATH="from_hook_toto:$LUA_PATH"
    # export LUA_CPATH="from_hook_tata:$LUA_CPATH"
    ${postShellHook}
  '';

  # count on luarocks to install it
    # luarocks install --tree $out ${name}
  installPhase = attrs.installPhase or ''

    echo "STARTED INSTALL"
    runHook preInstall


    echo "Looking for the folder fron $PWD"
    # set -x
    # TODO set it as $sourceRoot

    # make assumes sources are available in cwd
    # $rockspec
    # After the build is complete, it also installs the rock.
    # If no argument is given, it looks for a rockspec in the current directory
    # one problem here is that luarocks install packages in subfolders
    # so we patch luarocks !
    luarocks make --deps-mode=none --verbose --tree $out
    # folder=$(find . -mindepth 2 -maxdepth 2 -type d -path '*$}*'|head -n1)

    # to prevent collision when creating the environment
    # might be possible to prevent htat with a better default config for luarocks
    # also added -f as it doesn't always exist
# building path(s) ‘/nix/store/jc5ln503d83z24jbbkw91c06dqr54l59-lua-5.2.3-env’
# collision between `/nix/store/8vzwia4dynqf367psvi517bjsk3pfkys-lua-5.2.3-lua_cliargs-3.0-1/lib/luarocks/rocks-5.2/manifest' and `/nix/store/s24bdjjr506vdpk71isakl600ryg5yfa-lua-5.2.3-busted-2.0.rc12-1/lib/luarocks/rocks-5.2/manifest'

    rm -f $out/lib/luarocks/rocks-5.2/manifest
    # install --deps-mode=none should work too

  #   addToLuaSearchPath LUA_PATH "$out/lib/lua/${lua.luaversion}" "/?.lua"
  #   addToLuaSearchPath LUA_PATH "$out/share/lua/${lua.luaversion}" "/?.lua"
  #   addToLuaSearchPath LUA_CPATH "$out/lib/lua/${lua.luaversion}" "/?.so"
  #   addToLuaSearchPath LUA_CPATH "$out/share/lua/${lua.luaversion}" "/?.so"

  #   export LUA_PATH="from_install_toto:$LUA_PATH"
  #   export LUA_CPATH="from_install_tata:$LUA_CPATH"

  #   # /bin/pip install *.whl --no-index --prefix=$out --no-cache

    runHook postInstall

  #   echo "finished install"
  #   echo "LUA_PATH=$LUA_PATH"
  #   echo "LUA_CPATH=$LUA_CPATH"
  '';

  # installPhase = attrs.installPhase or ''
  #   runHook preInstall

  #   # mkdir -p "$out/${lua.libFolder}"
  #   # can be 5.2 for instance
  #   folder="$out/lib/lua/${lua.libFolder}"
  #   echo "install ran"
  #   export TOTO="YO MAN!"
  #   echo "installPhase run"
  #   echo "Checking for folder '$folder'"
  #   # if [ -d "$folder" ]; then
  #     # export LUA_PATH="toto:$LUA_PATH"
  #     # export LUA_CPATH="$folder:$LUA_CPATH"
  #   # fi

  #   runHook postInstall
  # '';

  passthru = {
    inherit lua; # The lua interpreter
  } // passthru;

  meta = with lib.maintainers; {
    # default to lua's platforms
    platforms = lua.meta.platforms;
  } // meta // {
    # add extra maintainer(s) to every package
    maintainers = (meta.maintainers or []) ++ [ ];
    # a marker for release utilities to discover python packages
    # isBuildLuaPackage = lua.meta.platforms;
  };
}))
