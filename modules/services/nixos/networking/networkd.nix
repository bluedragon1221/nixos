{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.networking.networkd;

  dhcp_enabled = cfg.static == null;
in
  lib.mkIf cfg.enable {
    networking = {
      wireless = {
        enable = true;
        networks.${cfg.ssid}.pskRaw = "ext:psk";
        secretsFile = cfg.pskFile;
      };

      useNetworkd = true;

      # Disable default networking stuff
      dhcpcd.enable = false;
      useDHCP = false;
      networkmanager.enable = false;
    };

    systemd.network = {
      enable = true;

      wait-online = {
        enable = true;
        ignoredInterfaces = ["docker0"];
      };

      networks."11-static-lan" = {
        name = "wl*";

        networkConfig =
          (
            if dhcp_enabled
            then {
              DHCP = "yes";
            }
            else {
              Address = cfg.static.ip;
              Gateway = cfg.static.gateway;
              # DNS is managed by systemd-resolvd (not specified here)
              DHCP = "no";
            }
          )
          // {
            # diable ipv6 addresses
            IPv6AcceptRA = "no";
            IPv6PrivacyExtensions = "no";
            LinkLocalAddressing = "no";
          };
      };
    };
  }
