{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.dufs;
in {
  imports = [./caddy-sidecar.nix];
  config.caddy.reverseProxy = "unix//run/dufs/dufs.sock";

  options.dufs = {
    settings = lib.mkOption {
      description = "dufs config file contents";
      type = lib.types.attrsOf lib.types.anything;
      default = {};
    };
  };
  config = {
    configData."dufs.yaml".text = builtins.toJSON cfg.settings;
    process.argv = [(lib.getExe pkgs.dufs) "--config" config.configData."dufs.yaml".path "--bind" "/run/dufs/dufs.sock"];

    systemd.service = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      startLimitBurst = 3;
      startLimitIntervalSec = 1;

      serviceConfig = {
        DynamicUser = true;
        Group = "caddy";

        RuntimeDirectory = "dufs";
        RuntimeDirectoryMode = "0750";
        UMask = "0007";

        Restart = "on-failure";

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectClock = true;
        PrivateNetwork = true;
        PrivateUsers = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];
        CapabilityBoundingSet = "";
        PrivateDevices = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictRealtime = true;
      };
    };
  };
}
