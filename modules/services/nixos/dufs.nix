{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.services.dufs;
in
  lib.mkIf cfg.enable {
    users.groups."fileserver" = {};

    system.services."dufs" = {
      _module.args = {inherit pkgs;};
      imports = [./service_modules/dufs.nix];

      caddy = {
        virtualHost = "files.ganymede";
        internal = true;
      };

      dufs.settings.serve-path = "/media";

      systemd.service.serviceConfig.SupplementaryGroups = "fileserver";
    };

    collinux.services.glance.homelabServices."files" = {
      url = "https://files.ganymede";
      icon = "mdi:folder";
    };
  }
