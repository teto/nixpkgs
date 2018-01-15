# Generic builder for lua packages
{ lib
, lua
, luarocks
, stdenv
, wrapLua
, unzip
, writeText
# Whether the derivation provides a lua module or not.
, toLuaModule
}:

{
name ? "${attrs.pname}-${attrs.version}"

, version

# by default prefix `name` e.g. "lua5.2-${name}"
, namePrefix ? lua.name + "-"

# Dependencies for building the package
, buildInputs ? []

# Dependencies needed for running the checkPhase.
# These are added to buildInputs when doCheck = true.
, checkInputs ? []

# propagate build dependencies so in case we have A -> B -> C,
# C can import package A propagated by B
, propagatedBuildInputs ? []
, propagatedNativeBuildInputs ? []

# used to disable derivation, useful for specific lua versions
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
then throw "${name} not supported for interpreter ${lua}"
else

let
  # todo use this
  luarocks_config = writeText "luarocksConfig" ''
    local_cache = ""
  '';
in
toLuaModule ( lua.stdenv.mkDerivation (
builtins.removeAttrs attrs ["disabled" "checkInputs"] // {

  name = namePrefix + name;

  buildInputs = [ wrapLua luarocks ]
    ++ buildInputs
    ++ lib.optionals doCheck checkInputs
    ;

  # propagate lua to active setup-hook in nix-shell
  propagatedBuildInputs = propagatedBuildInputs ++ [ lua ];
  doCheck = false;

  # that works only for src.rock
  setSourceRoot= let
    name_only=(builtins.parseDrvName name).name;
    in ''
    folder=$(find . -mindepth 2 -maxdepth 2 -type d -path '*${name_only}*'|head -n1)
    echo "folder found ='$folder'"
    sourceRoot=$folder
  '';

  configurePhase = ''
    echo "Skipping configurePhase as luarocks is in charge"
  '';

  buildPhase = ''
    runHook preBuild
    export LUAROCKS_CONFIG="$PWD/luarocks_cfg"
    echo "local_cache = '$PWD'" > "$LUAROCKS_CONFIG"


    # TODO record in nix package the type of luarocks package it is, if it's make based,
    # one might want to patch shebangs for instance
    patchShebangs .

    runHook postBuild
  '';


  # even here we should export LUA_PATH ?
  postFixup = lib.optionalString (!dontWrapLuaPrograms) ''
    wrapLuaPrograms
  '' + attrs.postFixup or '''';


  # inspired from build-python-setup-tools
  shellHook = attrs.shellHook or ''
    ${preShellHook}
      echo "SHELL HOOK from lua-mk-derivation"
      export MATTATOR="HELLO WORLD"
    # export LUA_PATH="from_hook_toto:$LUA_PATH"
    # export LUA_CPATH="from_hook_tata:$LUA_CPATH"
    ${postShellHook}
  '';

  installPhase = attrs.installPhase or ''
    runHook preInstall

    # luarocks make assumes sources are available in cwd
    # After the build is complete, it also installs the rock.
    # If no argument is given, it looks for a rockspec in the current directory
    # one problem here is that luarocks install packages in subfolders
    # so we patch luarocks !
    luarocks make --deps-mode=none --verbose --tree $out

    # to prevent collisions when creating environments
    # also added -f as it doesn't always exist
    rm -f $out/lib/luarocks/rocks-5.2/manifest

    runHook postInstall
  '';

  passthru = {
    inherit lua; # The lua interpreter
  } // passthru;

  meta = with lib.maintainers; {
    # default to lua's platforms
    platforms = lua.meta.platforms;
  } // meta // {
    # add extra maintainer(s) to every package
    maintainers = (meta.maintainers or []) ++ [ ];
  };
}))
