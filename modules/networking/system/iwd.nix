{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.networking;
in
  lib.mkIf (cfg.enable && cfg.wifiDaemon == "iwd") {
    networking = {
      wireless.iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = true; # use builtin dhcp client
            AddressRandomization = "once";
          };
          Network.NameResolvingService = "systemd"; # either systemd or resolvconf
        };
      };

      # Disable default networking stuff
      dhcpcd.enable = false;
      useDHCP = false;
      networkmanager.enable = false;
    };
  }
