# Global configuration for mininet
{ config, lib, pkgs, ... }:

with lib;

let

  cfg  = config.programs.mininet;
  # cfgOvs = config.virtualisation.vswitch;

  mn = pkgs.pythonPackages.mininet;

in
{
  ###### interface

  options = {

    programs.mininet = {
      enable = mkOption { type = types.bool;
        default = false;
        description = ''
          Whether to enable Open vSwitch. A configuration daemon (ovs-server)
          will be started.
          '';
      };

      # extraConfig = mkOption {
      #   type = types.lines;
      #   default = "";
      #   description = ''
      #     Extra configuration text appended to <filename>ssh_config</filename>.
      #     See <citerefentry><refentrytitle>ssh_config</refentrytitle><manvolnum>5</manvolnum></citerefentry>
      #     for help.
      #   '';
      # };

    };

  };

  config = mkIf cfg.enable {

    virtualisation.vswitch = {
      enable = true;
    };

    # $install gcc make socat psmisc xterm ssh iperf iproute2 telnet \
            # python-setuptools cgroup-bin ethtool help2man \
            # pyflakes pylint pep8 python-pexpect
    environment.systemPackages = with pkgs; [
      mn iperf mininet-mnexec openflowswitch telnet
      ethtool iproute2 socat
    ];
    # environment.variables = { EDITOR = mkOverride 900 "vim"; };

    services.telnet = {
      enable = true;
      # port
    };

    # make it setuid ?
    security.wrappers = {
      # sudo.source = "${pkgs.sudo.out}/bin/sudo";
      # todo use mininet
      mn.source = "${mn.out}/bin/mn";
    };
  };
}

