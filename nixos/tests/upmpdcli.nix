{ ... }:
{
  name = "upmpdcli";

  nodes.machine = {
    services.upmpdcli.enable = true;
    services.mpd = {
      enable = true;
      settings.audio_output = [
        {
          type = "null";
          name = "Null output";
        }
      ];
    };
  };

  testScript = ''
    machine.wait_for_unit("mpd.service")
    machine.wait_for_unit("upmpdcli.service")
    machine.wait_for_open_port(49152)
    machine.succeed("test -d /var/cache/upmpdcli")
    machine.succeed("systemctl restart upmpdcli.service")
    machine.wait_for_open_port(49152)
    machine.succeed("test $(systemctl show upmpdcli.service -p NRestarts --value) = 0")
  '';
}
