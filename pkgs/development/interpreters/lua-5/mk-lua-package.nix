/* Generic builder for Python packages that come without a setup.py. */

{ lib
, lua
, luarocks
, stdenv
, wrapLua
# , unzip

# adds a postUnpackHooks
, ensureNewerSourcesHook
}:

{ name

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

lua.stdenv.mkDerivation (
builtins.removeAttrs attrs ["disabled" "checkInputs"] // rec {

  # pname = name;
  # TODO fix
  pname = namePrefix + name;
    # name = "lua${lua.luaversion}-" + attrs.name;

  # inherit luaPath;

  # luarocks
  buildInputs = [ wrapLua luarocks ] ++ buildInputs
    # ++ [ (ensureNewerSourcesHook { year = "1980"; }) ]
    ++ lib.optionals doCheck checkInputs;

  # propagate python/setuptools to active setup-hook in nix-shell
  # propagatedBuildInputs = propagatedBuildInputs ++ [ lua ];
  propagatedNativeBuildInputs = propagatedNativeBuildInputs ++ [ lua ];
  # Python packages don't have a checkPhase, only an installCheckPhase
  doCheck = false;
  doInstallCheck = doCheck;

  rockspec_name = name + "-" + version + ".rockspec";

  postUnpack=''
    # download the rockspec
    # ideally put it in the store ?
    luarocks download --rockspec ${name} ${version}
    # ${name}

    # now remove all dependencies from the rockspec; there is a check on the
    # filename so it should
    # TODO replace the archive too
    perl -0pe 's/dependencies = {((.|\n)+?)}//g' ${rockspec_name} > ${rockspec_name}
    # perl -0pe 's/dependencies = {((.|\n)+?)}//g'  lua_cliargs-3.0-1.rockspec
  '';
  preBuild = ''
    makeFlagsArray=(
      PREFIX=$out
      LUA_LIBDIR="$out/lib/lua/${lua.luaversion}"
      LUA_INC="-I${lua}/include");

      # strip the rockspec of its dependencies
      # aka remove all its attributes
      # and change the source (assumed it's unpacked already)
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
    export LUA_PATH="from_hook_toto:$LUA_PATH"
    export LUA_CPATH="from_hook_tata:$LUA_CPATH"
    ${postShellHook}
  '';

  # count on luarocks to install it
  installPhase = attrs.installPhase or ''

    echo "Started install"
    runHook preInstall

    # TODO set the stripped rockspec
    # luarocks make
    luarocks make --tree $out ${name}



    # luarocks install --tree $out ${name}

    #


  #   addToLuaSearchPath LUA_PATH "$out/lib/lua/${lua.luaversion}" "/?.lua"
  #   addToLuaSearchPath LUA_PATH "$out/share/lua/${lua.luaversion}" "/?.lua"
  #   addToLuaSearchPath LUA_CPATH "$out/lib/lua/${lua.luaversion}" "/?.so"
  #   addToLuaSearchPath LUA_CPATH "$out/share/lua/${lua.luaversion}" "/?.so"

  #   export LUA_PATH="from_install_toto:$LUA_PATH"
  #   export LUA_CPATH="from_install_tata:$LUA_CPATH"

  #   # pushd dist
  #   # /bin/pip install *.whl --no-index --prefix=$out --no-cache
  #   # popd

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
    # isBuildPythonPackage = lua.meta.platforms;
  };
})
