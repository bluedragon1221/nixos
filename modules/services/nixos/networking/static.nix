{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.networking.static;
in
  lib.mkIf cfg.enable {
    networking = {
      wireless = {
        enable = true;
        networks.${cfg.ssid}.pskRaw = "ext:psk";
        secretsFile = config.age.secrets.${cfg.pskFile}.path;
      };

      # Disable default networking stuff
      dhcpcd.enable = false;
      useDHCP = false;
      networkmanager.enable = false;
    };

    systemd.network = {
      enable = true;
      networks."10-static-lan" = {
        name = "wl*";

        networkConfig = {
          Address = "${cfg.ip}/24";
          Gateway = cfg.gateway;
          DNS = "1.1.1.1";
          DHCP = "no";

          # diable ipv6 addresses
          IPv6AcceptRA = "no";
          IPv6PrivacyExtensions = "no";
          LinkLocalAddressing = "no";
        };
      };
    };
  }
