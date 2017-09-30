/* Generic builder for Python packages that come without a setup.py. */

{ lib
, lua
, stdenv
, wrapLua
, unzip
, ensureNewerSourcesHook
}:

{ name

# by default prefix `name` e.g. "python3.3-${name}"
, namePrefix ? lua.name + "-"

# Dependencies for building the package
, buildInputs ? []

# Dependencies needed for running the checkPhase.
# These are added to buildInputs when doCheck = true.
, checkInputs ? []

# propagate build dependencies so in case we have A -> B -> C,
# C can import package A propagated by B
, propagatedBuildInputs ? []

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

stdenv.mkDerivation (
builtins.removeAttrs attrs ["disabled" "checkInputs"] // {

  name = namePrefix + name;

  # inherit luaPath;

  buildInputs = [ wrapLua ] ++ buildInputs
    # ++ [ (ensureNewerSourcesHook { year = "1980"; }) ]
    ++ lib.optionals doCheck checkInputs;

  # propagate python/setuptools to active setup-hook in nix-shell
  propagatedBuildInputs = propagatedBuildInputs ++ [ lua ];

  # Python packages don't have a checkPhase, only an installCheckPhase
  doCheck = false;
  doInstallCheck = doCheck;


  # even here we should export LUA_PATH ?
  postFixup = lib.optionalString (!dontWrapLuaPrograms) ''
    wrapLuaPrograms
  '' + attrs.postFixup or '''';

  shellHook = attrs.shellHook or ''
    ${preShellHook}
      echo "hello world"
      export PATH="$tmp_path/bin:$PATH"
      export MATTATOR="HELLO WORLD"
      # mkdir -p $tmp_path/
    ${postShellHook}
  '';

  installPhase = attrs.installPhase or ''
    runHook preInstall

    # mkdir -p "$out/${lua.libFolder}"
    # can be 5.2 for instance
    folder="$out/lib/lua/${lua.libFolder}"
    echo "install ran"
    export TOTO="YO MAN!"
    echo "installPhase run"
    echo "Checking for folder '$folder'"
    if [ -d "$folder" ]; then
      export LUA_PATH="$folder:$LUA_PATH"
      export LUA_CPATH="$folder:$LUA_CPATH"
    fi

    runHook postInstall
  '';

  passthru = {
    inherit lua; # The lua interpreter
  } // passthru;

  meta = with lib.maintainers; {
    # default to python's platforms
    platforms = lua.meta.platforms;
  } // meta // {
    # add extra maintainer(s) to every package
    maintainers = (meta.maintainers or []) ++ [ ];
    # a marker for release utilities to discover python packages
    # isBuildPythonPackage = lua.meta.platforms;
  };
})
