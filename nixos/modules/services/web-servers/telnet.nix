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

  };

  config = mkIf config.services.telnet.enable {

    systemd.services.gitweb = {
      description = "Telnet server";
      script = "${pkgs.telnet}/gitweb.cgi --fastcgi --nproc=1";
      # environment  = {
      #   FCGI_SOCKET_PATH = "/run/gitweb/gitweb.sock";
      # };
      serviceConfig = {
        User = "telnetd";
        Group = "telnetd";
        RuntimeDirectory = [ "telnetd" ];
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

