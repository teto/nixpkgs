# { config, }:
{ config, lib, neovimUtils, ... }:
let
  generateInitNvim = toto:
    ''placeholder'';

  pluginWithConfigType = with lib; types.submodule {
    options = {
      config = mkOption {
        type = types.nullOr types.lines;
        description =
          "Script to configure this plugin. The scripting language should match type.";
        default = null;
      };

      optional = mkEnableOption "optional" // {
        description = "Don't load by default (load with :packadd)";
      };

      plugin = mkOption {
        type = types.package;
        description = "vim plugin";
      };

    };
  };

in
{

  options = {
      plugins = lib.mkOption {
        type = with lib.types; listOf (either package pluginWithConfigType);
        default = [ ];
        example = lib.literalExpression ''
          with pkgs.vimPlugins; [
            yankring
            vim-nix
            { plugin = vim-startify;
              config = "let g:startify_change_to_vcs_root = 0";
            }
          ]
        '';
        description = ''
          List of vim plugins to install optionally associated with
          configuration to be placed in init.vim.

          This option is mutually exclusive with {var}`configure`.
        '';
      };

    packpathDirs = lib.mkOption {
      readOnly = true;
      # type = any;
      # lib.types.lines;
      description = ''
      '';
    };

    initLua = lib.mkOption {
      readOnly = true;
      type = lib.types.lines;
      description = ''
      '';
    };

    # settings = mkOption {
    #   type = types.attrsOf kernelItem;
    #   example = literalExpression '' with lib.kernel; {
    #     "9P_NET" = yes;
    #     USB = option yes;
    #     MMC_BLOCK_MINORS = freeform "32";
    #   }'';
    #   description = ''
    #     Structured kernel configuration.
    #   '';
    # };
  };


  config = {
    initLua = "toto"; # generateInitNvim config.plugins;

    packpathDirs = neovimUtils.normalizedPluginsToVimPackage config.plugins;
  };
}
