{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.networking.networkmanager;
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

    services.tailscale.extraSetFlags = lib.optional config.collinux.services.networking.tailscale.enable "--accept-dns=true";
  }
