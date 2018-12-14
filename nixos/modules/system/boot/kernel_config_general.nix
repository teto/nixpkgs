{ lib, config, ... }:

with lib;
{

  # TODO move the check here
  options = {

    enforceRequiredConfig = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Wether to update the neovim manifest for remote plugins (<command>:UpdateRemotePlugins</command>).
      '';
    };

    requiredKernelConfig = mkOption {
      type = types.listOf types.str;
      default = true;
      description = ''
        Wether to update the neovim manifest for remote plugins (<command>:UpdateRemotePlugins</command>).
      '';
    };

    structuredConfig = mkOption {
      type = types.listOf types.package;
      readOnly = true;
      description = ''
        Generated from dependencies.
      '';
    };

    # TODO environment.systemPackages
    dependencies = mkOption {
      type = types.listOf types.package;
      default = [];
      description = ''
        Wether to update the neovim manifest for remote plugins (<command>:UpdateRemotePlugins</command>).
      '';
    };
  };


  config = {

  };

}
