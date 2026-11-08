{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let

  gid = config.ids.gids.mediatomb;
  cfg = config.services.mediatomb;
  opt = options.services.mediatomb;
  name = cfg.package.pname;
  pkg = cfg.package;
  # configuration on media directory
  mediaDirectory = {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = ''
          Absolute directory path to the media directory to index.
        '';
      };
      recursive = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the indexation must take place recursively or not.";
      };
      hidden-files = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to index the hidden files or not.";
      };
    };
  };
  # <directory location="/media" mode="inotify" recursive="yes" hidden-files="yes" media-type="Any" />
  toMediaDirectory =
    d:
    ''<directory location="${d.path}" mode="inotify" recursive="${lib.boolToYesNo d.recursive}" hidden-files="${lib.boolToYesNo d.hidden-files}" media-type="Any" />'';

    freeboxRevolution6mappings = ''
        <map from="avi" to="video/x-msvideo"/>
        <map from="flv" to="video/x-flv"/>
        <map from="mkv" to="video/x-matroska"/>
        <map from="m2t" to="video/mp2t"/>
        <map from="m2ts" to="video/mp2t"/>
        <map from="mp4" to="video/mp4"/>
        <map from="mov" to="video/quicktime"/>
        <map from="mts" to="video/mp2t"/>
        <map from="ts"  to="video/mp2t"/>
        <map from="wmv" to="video/x-ms-wmv"/>
        <map from="mpa" to="video/mpeg"/>
        <map from="mpe" to="video/mpeg"/>
        <map from="mpeg" to="video/mpeg"/>
        <map from="mpg" to="video/mpeg"/>
        <map from="mpv2" to="video/mpeg"/>
        <map from="ogv" to="video/ogg"/>
        <map from="ogm" to="video/ogg"/>
        <map from="wmv" to="video/x-ms-wmv"/>
        <map from="wmv" to="video/x-ms-wmv"/>

        <map from="flac" to="audio/x-flac"/>
        <map from="mka" to="audio/x-matroska"/>
        <map from="mp2" to="audio/mpeg"/>
        <map from="mp3" to="audio/mpeg"/>
        <map from="oga" to="audio/ogg"/>
        <map from="wma" to="audio/x-ms-wma"/>

        <map from="jpe" to="image/jpeg"/>
        <map from="jpeg" to="image/jpeg"/>
        <map from="jpg" to="image/jpeg"/>
        <map from="gif" to="image/gif"/>
        <map from="png" to="image/png"/>

        <map from="ogg" to="application/ogg"/>
        <map from="ogx" to="application/ogg"/>
        <!-- /freebox V6 -->

        <map from="3gp" to="video/3gpp"/>
        <map from="asf" to="video/x-ms-asf"/>
        <map from="asr" to="video/x-ms-asf"/>
        <map from="asx" to="video/x-ms-asf"/>
        <map from="lsf" to="video/x-la-asf"/>
        <map from="lsx" to="video/x-la-asf"/>
        <map from="movie" to="video/x-sgi-movie"/>
        <map from="qt" to="video/quicktime"/>
        <map from="rv" to="video/vnd.rn-realvideo"/>
        <map from="wm"  to="video/x-ms-wm"/>
        <map from="wmx" to="video/x-ms-wmx"/>
        <map from="wvx" to="video/x-ms-wvx"/>

        <map from="aif" to="audio/x-aiff"/>
        <map from="aifc" to="audio/x-aiff"/>
        <map from="aiff" to="audio/x-aiff"/>
        <map from="au" to="audio/basic"/>
        <map from="kar" to="audio/midi"/>
        '';


  configText = lib.optionalString (!cfg.customCfg) ''
    <?xml version="1.0" encoding="UTF-8"?>
    <config version="2"
        xmlns="http://gerbera.io/config/2"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://gerbera.io/config/2 http://gerbera.io/config/2.xsd">
        <server>
          <ui enabled="yes" show-tooltips="yes">
            <accounts enabled="no" session-timeout="30">
              <account user="${name}" password="${name}"/>
            </accounts>
          </ui>
          <name>${cfg.serverName}</name>
          <udn>uuid:${cfg.uuid}</udn>
          <home override="yes">${cfg.dataDir}</home>
          <interface>${cfg.interface}</interface>
          <webroot>${pkg}/share/${name}/web</webroot>
          <pc-directory upnp-hide="${lib.boolToYesNo cfg.pcDirectoryHide}"/>
          <storage>
            <sqlite3 enabled="yes">
              <database-file>${name}.db</database-file>
            </sqlite3>
          </storage>
          ${lib.optionalString cfg.dsmSupport ''
            <custom-http-headers>
              <add header="X-User-Agent: redsonic"/>
            </custom-http-headers>

            <manufacturerURL>redsonic.com</manufacturerURL>
            <modelNumber>105</modelNumber>
          ''}
            ${lib.optionalString cfg.tg100Support ''
              <upnp-string-limit>101</upnp-string-limit>
            ''}
          <extended-runtime-options>
            <mark-played-items enabled="yes" suppress-cds-updates="yes">
              <string mode="prepend">*</string>
              <mark>
                <content>video</content>
              </mark>
            </mark-played-items>
          </extended-runtime-options>
        </server>

        <import follow-symlinks="yes" default-date="yes" import-mode="mt" nomedia-file=".nomedia" readable-names="yes" hidden-files="no">
          <autoscan use-inotify="auto">
          ${lib.concatMapStrings toMediaDirectory cfg.mediaDirectories}
          </autoscan>
          <scripting script-charset="UTF-8">
            <script-folder>
              <common>${pkg}/share/${name}/js</common>
            </script-folder>
            <virtual-layout type="builtin"/>
          </scripting>
          ${cfg.mappings}
        </import>
        ${cfg.transcoding}
      </config>
  '';
  defaultFirewallRules = {
    # udp 1900 port needs to be opened for SSDP (not configurable within
    # mediatomb/gerbera) cf.
    # https://docs.gerbera.io/en/latest/run.html?highlight=udp%20port#network-setup
    allowedUDPPorts = [
      1900
      cfg.port
    ];
    allowedTCPPorts = [ cfg.port ];
  };

in
{

  ###### interface

  options = {

    services.mediatomb = {

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable the Gerbera/Mediatomb DLNA server.
        '';
      };

      serverName = lib.mkOption {
        type = lib.types.str;
        default = "Gerbera (Mediatomb)";
        description = ''
          How to identify the server on the network.
        '';
      };

      package = lib.mkPackageOption pkgs "gerbera" { };

      ps3Support = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable ps3 specific tweaks.
          WARNING: incompatible with DSM 320 support.
        '';
      };

      dsmSupport = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable D-Link DSM 320 specific tweaks.
          WARNING: incompatible with ps3 support.
        '';
      };

      tg100Support = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable Telegent TG100 specific tweaks.
        '';
      };

      transcoding = lib.mkOption {
        type = lib.types.lines;
        default = ''
          <transcoding enabled="no">
          </transcoding>
        '';
        example = ''
          <transcoding enabled="yes">
            <mimetype-profile-mappings>
              <transcode mimetype="audio/ogg" using="ogg2mp3" />
            </mimetype-profile-mappings>
          </transcoding>
        '';
        description = ''
          The XML transcoding section to include in the Gerbera configuration.
        '';
      };

      mappings = lib.mkOption {
        type = lib.types.str;
        defaultText = lib.literalExpression "placeholder";
        default = ''
          <mappings>
            <extension-mimetype ignore-unknown="no">
              <map from="mp3" to="audio/mpeg"/>
              <map from="ogx" to="application/ogg"/>
              <map from="ogv" to="video/ogg"/>
              <map from="oga" to="audio/ogg"/>
              <map from="ogg" to="audio/ogg"/>
              <map from="ogm" to="video/ogg"/>
              <map from="asf" to="video/x-ms-asf"/>
              <map from="asx" to="video/x-ms-asf"/>
              <map from="wma" to="audio/x-ms-wma"/>
              <map from="wax" to="audio/x-ms-wax"/>
              <map from="wmv" to="video/x-ms-wmv"/>
              <map from="wvx" to="video/x-ms-wvx"/>
              <map from="wm" to="video/x-ms-wm"/>
              <map from="wmx" to="video/x-ms-wmx"/>
              <map from="m3u" to="audio/x-mpegurl"/>
              <map from="pls" to="audio/x-scpls"/>
              <map from="flv" to="video/x-flv"/>
              <map from="mkv" to="video/x-matroska"/>
              <map from="mka" to="audio/x-matroska"/>
              ${lib.optionalString cfg.ps3Support ''
                <map from="avi" to="video/divx"/>
              ''}
              ${lib.optionalString cfg.dsmSupport ''
                <map from="avi" to="video/avi"/>
              ''}
              ${lib.optionalString true freeboxRevolution6mappings}
            </extension-mimetype>
            <mimetype-upnpclass>
              <map from="audio/*" to="object.item.audioItem.musicTrack"/>
              <map from="video/*" to="object.item.videoItem"/>
              <map from="image/*" to="object.item.imageItem"/>
            </mimetype-upnpclass>
            <mimetype-contenttype>
              <treat mimetype="audio/mpeg" as="mp3"/>
              <treat mimetype="application/ogg" as="ogg"/>
              <treat mimetype="audio/ogg" as="ogg"/>
              <treat mimetype="audio/x-flac" as="flac"/>
              <treat mimetype="audio/x-ms-wma" as="wma"/>
              <treat mimetype="audio/x-wavpack" as="wv"/>
              <treat mimetype="image/jpeg" as="jpg"/>
              <treat mimetype="audio/x-mpegurl" as="playlist"/>
              <treat mimetype="audio/x-scpls" as="playlist"/>
              <treat mimetype="audio/x-wav" as="pcm"/>
              <treat mimetype="audio/L16" as="pcm"/>
              <treat mimetype="video/x-msvideo" as="avi"/>
              <treat mimetype="video/mp4" as="mp4"/>
              <treat mimetype="audio/mp4" as="mp4"/>
              <treat mimetype="application/x-iso9660" as="dvd"/>
              <treat mimetype="application/x-iso9660-image" as="dvd"/>
            </mimetype-contenttype>
          </mappings>
        '';

        description = ''
          The XML mappings section to include in the Gerbera configuration.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/${name}";
        defaultText = lib.literalExpression ''"/var/lib/''${config.${opt.package}.pname}"'';
        description = ''
          The directory where Gerbera/Mediatomb stores its state, data, etc.
        '';
      };

      pcDirectoryHide = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to list the top-level directory or not (from upnp client standpoint).
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "mediatomb";
        description = "User account under which the service runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "mediatomb";
        description = "Group account under which the service runs.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 49152;
        description = ''
          The network port to listen on.
        '';
      };

      interface = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          A specific interface to bind to.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If false (the default), this is up to the user to declare the firewall rules.
          If true, this opens port 1900 (tcp and udp) and the port specified by
          {option}`sercvices.mediatomb.port`.

          If the option {option}`services.mediatomb.interface` is set,
          the firewall rules opened are dedicated to that interface. Otherwise,
          those rules are opened globally.
        '';
      };

      uuid = lib.mkOption {
        type = lib.types.str;
        default = "fdfc8a4e-a3ad-4c1d-b43d-a2eedb03a687";
        description = ''
          A unique (on your network) to identify the server by.
        '';
      };

      mediaDirectories = lib.mkOption {
        type = with lib.types; listOf (submodule mediaDirectory);
        default = [ ];
        description = ''
          Declare media directories to index.
        '';
        example = [
          {
            path = "/data/pictures";
            recursive = false;
            hidden-files = false;
          }
          {
            path = "/data/audio";
            recursive = true;
            hidden-files = false;
          }
        ];
      };

      customCfg = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Allow the service to create and use its own config file inside the `dataDir` as
          configured by {option}`services.mediatomb.dataDir`.
          Deactivated by default, the service then runs with the configuration generated from this module.
          Otherwise, when enabled, no service configuration is generated. Gerbera/Mediatomb then starts using
          config.xml within the configured `dataDir`. It's up to the user to make a correct
          configuration file.
        '';
      };

    };
  };

  ###### implementation

  config =
    let
      binaryCommand = "${pkg}/bin/${name}";
      interfaceFlag = lib.optionalString (cfg.interface != "") "--interface ${cfg.interface}";
      configFlag = lib.optionalString (
        !cfg.customCfg
      ) "--config ${pkgs.writeText "config.xml" configText}";
    in
    lib.mkIf cfg.enable {
      systemd.services.mediatomb = {
        description = "${cfg.serverName} media Server";
        # Gerbera might fail if the network interface is not available on startup
        # https://github.com/gerbera/gerbera/issues/1324
        wants = [ "network-online.target" ];
        after = [
          "network.target"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${binaryCommand} --port ${toString cfg.port} ${interfaceFlag} ${configFlag} --home ${cfg.dataDir}";
        serviceConfig.User = cfg.user;
        serviceConfig.Group = cfg.group;
      };

      users.groups = lib.optionalAttrs (cfg.group == "mediatomb") {
        mediatomb.gid = gid;
      };

      users.users = lib.optionalAttrs (cfg.user == "mediatomb") {
        mediatomb = {
          isSystemUser = true;
          group = cfg.group;
          home = cfg.dataDir;
          createHome = true;
          description = "${name} DLNA Server User";
        };
      };

      # Open firewall only if users enable it
      networking.firewall = lib.mkMerge [
        (lib.mkIf (cfg.openFirewall && cfg.interface != "") {
          interfaces."${cfg.interface}" = defaultFirewallRules;
        })
        (lib.mkIf (cfg.openFirewall && cfg.interface == "") defaultFirewallRules)
      ];
    };
}
