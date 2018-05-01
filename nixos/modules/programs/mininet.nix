# Global configuration for mininet
{ config, lib, pkgs, ... }:

with lib;

let

  cfg  = config.programs.mininet;
  cfgOvs = config.virtualisation.vswitch;


in
{
  ###### interface

  options = {

    programs.mininet = {


      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration text appended to <filename>ssh_config</filename>.
          See <citerefentry><refentrytitle>ssh_config</refentrytitle><manvolnum>5</manvolnum></citerefentry>
          for help.
        '';
      };

    };

  };

  # make it setuid ?
  config = {

    # programs.ssh.setXAuthLocation =
      # mkDefault (config.services.xserver.enable || config.programs.ssh.forwardX11 || config.services.openssh.forwardX11);

    # SSH configuration. Slight duplication of the sshd_config
    # generation in the sshd service.
    # environment.etc."ssh/ssh_config".text =
    # FIXME: this should really be socket-activated for über-awesomeness.
    # systemd.user.services.ssh-agent = mkIf cfg.startAgent
    #   { description = "SSH Agent";
    #     wantedBy = [ "default.target" ];
    #     serviceConfig =
    #       { ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-agent";
    #         ExecStart =
    #             "${cfg.package}/bin/ssh-agent " +
    #             optionalString (cfg.agentTimeout != null) ("-t ${cfg.agentTimeout} ") +
    #             "-a %t/ssh-agent";
    #         StandardOutput = "null";
    #         Type = "forking";
    #         Restart = "on-failure";
    #         SuccessExitStatus = "0 2";
    #       };
    #     # Allow ssh-agent to ask for confirmation. This requires the
    #     # unit to know about the user's $DISPLAY (via ‘systemctl
    #     # import-environment’).
    #     environment.SSH_ASKPASS = optionalString config.services.xserver.enable askPasswordWrapper;
    #     environment.DISPLAY = "fake"; # required to make ssh-agent start $SSH_ASKPASS
    #   };

      config.virtualisation.vswitch = {
        enable = true;
      };
    environment.systemPackages = [ pkgs.python.pkgs.mininet iperf ];
    # environment.variables = { EDITOR = mkOverride 900 "vim"; };

    # environment.extraInit = optionalString cfg.startAgent
    #   ''
    #     if [ -z "$SSH_AUTH_SOCK" -a -n "$XDG_RUNTIME_DIR" ]; then
    #       export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
    #     fi
    #   '';

    # environment.variables.SSH_ASKPASS = optionalString config.services.xserver.enable askPassword;

  };
}

