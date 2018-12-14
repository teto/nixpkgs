# Hooks for building lua packages.
{
  lua,
  lib,
  makeSetupHook,
  runCommand,
}:

let
  callPackage = lua.pkgs.callPackage;
in
{

  luarocksCheckHook = callPackage (
    { luarocks }:
    makeSetupHook {
      name = "luarocks-check-hook";
      propagatedBuildInputs = [ luarocks ];
    } ./luarocks-check-hook.sh
  ) { };

  # luarocks installs data in a non-overridable location. Until a proper luarocks patch,
  # we move the files around ourselves
  luarocksMoveDataFolder = callPackage (
    { }:
    makeSetupHook {
      name = "luarocks-move-rock";
      propagatedBuildInputs = [ ];
    } ./luarocks-move-data.sh) {};

  # # TODO this hook should generate the luarocks config
  # luarocks-configure-hook =
  #   let
  #     luarocks_config = "luarocks-config.lua";
  #     hook = ./luarocks-configure-hook.sh;
  #     luarocks_content = let
  #       generatedConfig = lua.pkgs.lib.generateLuarocksConfig {
  #         externalDeps = externalDeps ++ externalDepsGenerated;
  #         inherit extraVariables;
  #         inherit rocksSubdir;
  #         inherit requiredLuaRocks;
  #       };
  #       in writeText "luarocks-config"
  #         ''
  #         ${generatedConfig}
  #         ${extraConfig}
  #       '';
  #   in runCommand "luarocks-configure-hook.sh" {
  #     # hum doesn't seem to like caps !! BUG ?
  #     luapathsearchpaths=lib.escapeShellArgs LuaPathSearchPaths;
  #     luacpathsearchpaths=lib.escapeShellArgs LuaCPathSearchPaths;
  #   } ''
  #     cp ${hook} hook.sh
  #     substituteAllInPlace hook.sh
  #     mv hook.sh $out
  #   '';

  luarocksInstallHook = callPackage ({ luarocks }:
    makeSetupHook {
      name = "luarocks-install-hook";
      deps = [ luarocks ];
      substitutions = {
        # inherit pythonCheckInterpreter setuppy;
      };
    } ./luarocks-install-hook.sh) {};

  # luaToVimPluginHook = callPackage ({ }:
  #   makeSetupHook {
  #     name = "toVimPlugin-check-hook";
  #     deps = [ ];
  #     substitutions = {
  #       # inherit pythonCheckInterpreter setuppy;
  #     };
  #   } ./to-vim-plugin.sh) {};


}
