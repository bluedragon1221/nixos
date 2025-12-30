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
        dns = "systemd-resolved";
        dhcp = "internal";
        enable = true;
      };

      dhcpcd.enable = false;
      useNetworkd = false;
    };

    systemd.network.enable = false;

    services.tailscale.extraSetFlags = lib.optional config.collinux.services.networking.tailscale.enable "--accept-dns=true";
  }
