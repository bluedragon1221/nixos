{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.goaccess;
in {
  options."caddy-goaccess" = {
    timeZone = lib.mkOption {
      type = lib.types.str;
      description = "time zone";
    };
    logFile = lib.mkOption {
      type = lib.types.str;
      description = "caddy log file for goaccess to read (must be chmod 775)";
    };
    websocketUrl = lib.mkOption {
      type = lib.types.str;
      description = "url that the frontend should use to attach to the service websocket";
    };
  };
  config = let
    settings = {
      unix-socket = "/run/caddy-goaccess/socket";
      ws-url = cfg.websocketUrl;

      date-format = "%s";
      log-format = "CADDY";
      tz = cfg.timeZone;
      log-file = cfg.logFile;
      geoip-database = inputs.geolite-db;

      output = "/run/caddy-goaccess/index.html";
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
  in {
    configData."goaccess.conf".text = settings |> builtins.mapAttrs (k: v: "${k} ${toString v}") |> builtins.attrValues |> lib.concatStringsSep "\n";
    services."caddy-goaccess" = {
      systemd.socket = {
        description = "caddy-goaccess uds";
        socketConfig = {
          ListenStream = "/run/caddy-goaccess/socket";
          SocketMode = "0660";
          SocketUser = "goaccess";
          SocketGroup = "caddy";
        };
        wantedBy = ["sockets.target"];
      };

      systemd.service = {
        description = "GoAccess Real-Time Log Analyzer";
        restartIfChanged = true;
        wants = ["network-online.target" "caddy.service"];
        after = ["network-online.target" "caddy.service"];
        requires = ["caddy-goaccess.socket"];

        serviceConfig = {
          Type = "simple";

          DynamicUser = true;
          SupplimentaryGroup = "caddy"; # to read caddy log files
          RuntimeDirectory = "caddy-goaccess"; # /run/caddy-goaccess
          ExecStart = "${pkgs.goaccess}/bin/goaccess -p ${config.configData."goaccess.conf".path}";

          # hardening stuff
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
    };
  };
}
