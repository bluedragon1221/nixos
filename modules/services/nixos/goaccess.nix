{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.collinux.services.goaccess;

  settings = {
    date-format = "%s";
    log-format = "CADDY";
    tz = config.time.timeZone;
    log-file = "/var/log/caddy/access-williamsfam.us.com.log";
    geoip-database = inputs.geolite-db;

    ws-url = "wss://stats.ganymede:443/ws";
    port = cfg.port;
    addr = cfg.listenAddr;

    real-time-html = "true";
    output = "/var/www/goaccess/index.html";
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

  settingsFile = pkgs.writeText "goaccess.conf" (settings |> builtins.mapAttrs (k: v: "${k} ${toString v}") |> builtins.attrValues |> lib.concatStringsSep "\n");
in {
  config = lib.mkIf cfg.enable {
    users.groups."goaccess" = {};
    users.users."goaccess" = {
      isSystemUser = true;
      group = "goaccess";
      extraGroups = ["caddy"]; # to read caddy log files
    };

    systemd.services."goaccess" = {
      description = "GoAccess Real-Time Log Analyzer";
      restartIfChanged = true;
      wants = ["network-online.target" "caddy.service"];
      after = ["network-online.target" "caddy.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "goaccess";
        Type = "simple";

        ReadWritePaths = "/var/www/goaccess";
        WorkingDirectory = "/var/www/goaccess";
        ExecStart = "${pkgs.goaccess}/bin/goaccess -p ${settingsFile}";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
      };
    };

    systemd.tmpfiles.rules = ["d /var/www/goaccess/ 755 goaccess goaccess"];

    services.caddy.virtualHosts."stats.ganymede".extraConfig = ''
      tls internal

      root * /var/www/goaccess
      file_server

      reverse_proxy /ws 127.0.0.1:${toString cfg.port}
    '';
  };
}
