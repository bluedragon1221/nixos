{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.collinux.services.goaccess;

  modularService = {
    lib,
    config,
    options,
    ...
  }: let
    cfg = config.goaccess;

    settings =
      cfg.settings
      // {
        unix-socket = "/run/goaccess/goaccess.sock";
        output = "/run/goaccess/www/index.html";
      };
  in {
    options.goaccess = {
      package = lib.mkOption {
        description = "the `goaccess` package";
        type = lib.types.package;
      };
      settings = lib.mkOption {
        description = "goaccess.conf options";
        type = lib.types.attrsOf lib.types.str;
      };
    };

    config =
      {
        configData."goaccess.conf".text =
          settings
          |> lib.mapAttrsToList (k: v: "${k} ${v}")
          |> lib.concatStringsSep "\n";

        process.argv = [(lib.getExe cfg.package) "-p" config.configData."goaccess.conf".path];
      }
      // lib.optionalAttrs (options ? systemd) {
        systemd.service = {
          description = "GoAccess Real-Time Log Analyzer";
          restartIfChanged = true;
          wants = ["network-online.target" "caddy.service"];
          after = ["network-online.target" "caddy.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            DynamicUser = true;
            Group = "caddy";

            RuntimeDirectory = ["goaccess" "goaccess/www"];
            RuntimeDirectoryMode = "0750";
            UMask = "0007"; # socket -> 0770, files -> 0660

            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;

            Restart = "on-failure";
          };
        };
      };
  };
in {
  config = lib.mkIf cfg.enable {
    system.services."goaccess" = {
      imports = [modularService];
      goaccess = {
        package = pkgs.goaccess;
        settings = {
          date-format = "%s";
          log-format = "CADDY";
          tz = config.time.timeZone;
          log-file = "/var/log/caddy/access-williamsfam.us.com.log";
          geoip-database = toString inputs.geolite-db;

          ws-url = "wss://stats.ganymede:443/ws"; # url that the frontend uses to fetch data

          real-time-html = "true";
          external-assets = "true";
          all-static-files = "false";
          html-report-title = "stats@ganymede";
          hl-header = "true";
          agent-list = "false";
          with-output-resolver = "false";
          http-method = "yes";
          http-protocol = "yes";
          "4xx-to-unique-count" = "false";
          ignore-crawlers = "false";
          crawlers-only = "false";
          unknowns-as-crawlers = "false";
          real-os = "true";
        };
      };
    };

    services.caddy.virtualHosts."stats.ganymede".extraConfig = ''
      tls internal

      root * /run/goaccess/www
      file_server

      reverse_proxy /ws unix//run/goaccess/goaccess.sock
    '';

    collinux.services.glance.homelabServices."stats" = {
      url = "https://stats.ganymede";
      icon = "mdi:poll";
    };
  };
}
