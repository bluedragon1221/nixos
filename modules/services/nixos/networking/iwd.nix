{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.networking.iwd;
in
  lib.mkIf cfg.enable {
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
    systemd.network.enable = lib.mkForce false;
  }
