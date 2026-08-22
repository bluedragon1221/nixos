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

    ws-url = "wss://stats.ganymede:443/ws"; # url that the frontend uses to fetch data
    unix-socket = "/run/goaccess/goaccess.sock";

    real-time-html = "true";
    output = "/var/lib/goaccess/index.html";
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
    users.users.caddy.extraGroups = ["goaccess"];

    systemd.services."goaccess" = {
      description = "GoAccess Real-Time Log Analyzer";
      restartIfChanged = true;
      wants = ["network-online.target" "caddy.service"];
      after = ["network-online.target" "caddy.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "goaccess";
        Type = "simple";

        RuntimeDirectory = "goaccess";
        RuntimeDirectoryMode = "0770";
        UMask = "0007";

        StateDirectory = "goaccess";
        StateDirectoryMode = "0750"; # caddy must read this dir

        ExecStart = "${lib.getExe pkgs.goaccess} -p ${settingsFile}";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
      };
    };

    services.caddy.virtualHosts."stats.ganymede".extraConfig = ''
      tls internal

      root * /var/lib/goaccess
      file_server

      reverse_proxy /ws unix//run/goaccess/goaccess.sock
    '';

    collinux.services.glance.homelabServices."stats" = {
      url = "https://stats.ganymede";
      icon = "mdi:poll";
    };
  };
}
