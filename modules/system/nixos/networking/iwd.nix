{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.system.network.iwd;
in
  lib.mkIf cfg.enable {
    networking = {
      wireless.iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = !config.collinux.system.network.networkd.enable;
            AddressRandomization = "once";
            AddressRandomizationRange = "full";
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
