{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.system.network.networkmanager;
in
  lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        dhcp = "internal";
      };

      dhcpcd.enable = false;
    };
  }
