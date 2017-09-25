/* Generic builder for Python packages that come without a setup.py. */

{ lib
, lua
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

# Skip wrapping of python programs altogether
, dontWrapLuaPrograms ? false

, meta ? {}

, passthru ? {}

, doCheck ? false

, ... } @ attrs:


# Keep extra attributes from `attrs`, e.g., `patchPhase', etc.
if disabled
# .executable
then throw "${name} not supported for interpreter ${lua}"
else

lua.stdenv.mkDerivation (builtins.removeAttrs attrs ["disabled" "checkInputs"] // {

  name = namePrefix + name;

  # inherit luaPath;

  buildInputs = [ wrapLua ] ++ buildInputs
    ++ [ (ensureNewerSourcesHook { year = "1980"; }) ]
    # ++ (lib.optional (lib.hasSuffix "zip" attrs.src.name or "") unzip)
    ++ lib.optionals doCheck checkInputs;

  # propagate python/setuptools to active setup-hook in nix-shell
  # sure about setuptools ?
  propagatedBuildInputs = propagatedBuildInputs ++ [ lua ];

  # Python packages don't have a checkPhase, only an installCheckPhase
  doCheck = false;
  doInstallCheck = doCheck;


  postFixup = lib.optionalString (!dontWrapLuaPrograms) ''
    wrapLuaPrograms
  '' + attrs.postFixup or '''';


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
