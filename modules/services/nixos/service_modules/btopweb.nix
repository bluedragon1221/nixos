{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.btopweb;
in {
  _class = "service";

  imports = [./caddy-sidecar.nix];
  config.caddy.reverseProxy = "unix//run/btopweb/ttyd.sock";

  options.btopweb = {
    btopSettings = lib.mkOption {
      description = "configuration file for btop";
      type = lib.types.lines;
    };
  };

  config = {
    configData."btop.conf".text = cfg.btopSettings;
    process.argv = [
      (lib.getExe pkgs.ttyd)
      "-O"
      "-W"
      "-m"
      "1"
      "-i"
      "/run/btopweb/ttyd.sock"
      "-t"
      "renderType=canvas"
      "-t"
      "fontSize=16"
      (lib.getExe pkgs.btop)
      "-c"
      config.configData."btop.conf".path
    ];

    systemd.service = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        DynamicUser = true;
        Group = "caddy";

        RuntimeDirectory = "btopweb";
        RuntimeDirectoryMode = "0750";
        UMask = "0007";

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        AmbientCapabilities = "";
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@privileged" "@chown" "~@resources" "~@debug" "perf_event_open"];
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "default";
        PrivateDevices = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
        MemoryMax = "256M";
        TasksMax = 64;
        CPUQuota = "50%";
      };
    };
  };
}
