{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.collinux.services.filebrowser;
in
  lib.mkIf cfg.enable {
    users.groups."dufs" = {};
    users.users."dufs" = {
      isSystemUser = true;
      group = "dufs";
      extraGroups = ["fileserver"];
    };
    users.users.caddy.extraGroups = ["dufs"];

    systemd.services."dufs" = {
      description = "dufs file server";
      restartIfChanged = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.dufs} /media --bind /run/dufs/dufs.sock";

        RuntimeDirectory = "dufs";

        User = "dufs";
        Group = "dufs";
        UMask = "0007";

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;

        Restart = "on-failure";
      };
    };

    services.caddy.virtualHosts."files.ganymede".extraConfig = ''
      tls internal
      reverse_proxy unix//run/dufs/dufs.sock
    '';

    collinux.services.glance.homelabServices."files" = {
      url = "https://files.ganymede";
      icon = "mdi:folder";
    };
  }
