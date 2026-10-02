{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.collinux.services.dufs;

  modularService = {
    lib,
    config,
    options,
    ...
  }: let
    cfg = config.dufs;
  in {
    options.dufs = {
      package = lib.mkOption {
        description = "the `dufs` package";
        type = lib.types.package;
      };
      dir = lib.mkOption {
        description = "root directory of the fileserver";
        type = lib.types.str;
      };
    };
    config =
      {process.argv = [(lib.getExe cfg.package) cfg.dir "--bind" "/run/dufs/dufs.sock"];}
      // lib.optionalAttrs (options ? systemd) {
        systemd.service = {
          wants = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            DynamicUser = true;
            Group = "caddy";
            SupplementaryGroups = "fileserver";

            RuntimeDirectory = "dufs";
            RuntimeDirectoryMode = "0750";
            UMask = "0002";

            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
          };
        };
      };
  };
in
  lib.mkIf cfg.enable {
    users.groups."fileserver" = {};

    system.services."dufs" = {
      imports = [modularService];
      dufs = {
        package = pkgs.dufs;
        dir = "/media";
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
