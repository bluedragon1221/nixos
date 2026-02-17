{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.collinux.services.goaccess;

  geoip = pkgs.fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.02.13/GeoLite2-City.mmdb";
    hash = "sha256-FnvfGHH8b0506muEvlDXjgNKruorWeMXEbquGdZoH6Q=";
  };

  settings = {
    date-format = "%s";
    log-format = "CADDY";
    tz = "America/Chicago";

    ws-url = "wss://stats.ganymede:443/ws"; # url that the html uses to fetch from
    port = "7890";
    addr = "127.0.0.1";

    real-time-html = "true";
    log-file = "/var/log/caddy/access-williamsfam.us.com.log";
    geoip-database = "${geoip}";
    output = "/var/www/goaccess/index.html";
    external-assets = "true";
    all-static-files = "false";

    html-report-title = "Ganymede Stats";
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

  settingsFile = pkgs.writeText "goaccess.conf" (settings |> builtins.mapAttrs (k: v: "${k} ${v}") |> builtins.attrValues |> lib.concatStringsSep "\n");
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

      serviceConfig = {
        User = "goaccess";
        Type = "simple";

        WorkingDirectory = "/var/www/goaccess";
        ExecStart = "${pkgs.goaccess}/bin/goaccess -p ${settingsFile}";

        AmbientCapabilities = [];
        CapabilityBoundingSet = [
          "~CAP_RAWIO"
          "~CAP_MKNOD"
          "~CAP_AUDIT_CONTROL"
          "~CAP_AUDIT_READ"
          "~CAP_AUDIT_WRITE"
          "~CAP_SYS_BOOT"
          "~CAP_SYS_TIME"
          "~CAP_SYS_MODULE"
          "~CAP_SYS_PACCT"
          "~CAP_LEASE"
          "~CAP_LINUX_IMMUTABLE"
          "~CAP_IPC_LOCK"
          "~CAP_BLOCK_SUSPEND"
          "~CAP_WAKE_ALARM"
          "~CAP_SYS_TTY_CONFIG"
          "~CAP_MAC_ADMIN"
          "~CAP_MAC_OVERRIDE"
          "~CAP_NET_ADMIN"
          "~CAP_NET_BROADCAST"
          "~CAP_NET_RAW"
          "~CAP_SYS_ADMIN"
          "~CAP_SYS_PTRACE"
          "~CAP_SYSLOG"
        ];
        DevicePolicy = "closed";
        KeyringMode = "private";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
      };

      wantedBy = ["multi-user.target"];
    };

    systemd.tmpfiles.rules = [
      "d /var/www/goaccess/ 755 goaccess goaccess"
      "Z /var/www/goaccess 755 goaccess goaccess"
    ];

    networking.extraHosts = ''
      127.0.0.1 stats.ganymede
    '';

    services.caddy.virtualHosts."stats.ganymede".extraConfig = ''
      tls internal
      root * /var/www/goaccess
      file_server

      reverse_proxy /ws 127.0.0.1:7890
    '';
  };
}
