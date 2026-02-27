{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.system.network;
  enabled = cfg.wireless.dynamic;
in
  lib.mkIf enabled {
    networking = {
      wireless.iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = false; # always let networkd handle this
            AddressRandomization = "once";
            AddressRandomizationRange = "full";
          };
          Network.NameResolvingService = "systemd"; # either systemd or resolvconf
        };
      };
    };
  }
