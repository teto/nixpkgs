{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.telnet;

in
{

  options.services.telnet = {

    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enable telnetd.
      '';
    };

    port = mkOption {
      default = 12345;
      # lib.range 8000 8005 ++ lib.singleton 80;
      type = types.int;
      description = ''
        Port on which to listen.
      '';
    };

  };

  config = mkIf config.services.telnet.enable {

    # mkIf networking enabled ?
    # mkMerge
    networking.firewall.allowedUDPPorts =  [ cfg.port ];

    users.extraUsers.telnetd.uid = config.ids.uids.telnetd;
    users.extraGroups.telnetd.gid = config.ids.gids.telnetd;
        # uid = config.ids.uids.nginx;

    systemd.services.telnetd = {
      description = "Telnet server";

      script = "${pkgs.busybox}/bin/telnetd -p ${toString cfg.port} -b 127.0.0.1";
      # environment  = {
      #   FCGI_SOCKET_PATH = "/run/gitweb/gitweb.sock";
      # };
      serviceConfig = {
        User = "telnetd";
        Group = "telnetd";

        # RuntimeDirectory = [ "telnetd" ];
      };
      wantedBy = [ "multi-user.target" ];
    };

    # services.nginx = {
    #   virtualHosts.default = {
    #     locations."/gitweb/static/" = {
    #       alias = "${package}/static/";
    #     };
    #     locations."/gitweb/" = {
    #       extraConfig = ''
    #         include ${pkgs.nginx}/conf/fastcgi_params;
    #         fastcgi_param GITWEB_CONFIG ${cfg.gitwebConfigFile};
    #         fastcgi_pass unix:/run/gitweb/gitweb.sock;
    #       '';
    #     };
    #   };
  };


  meta.maintainers = with maintainers; [ teto ];

}

