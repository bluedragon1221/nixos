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
      wireless =
        if !config.collinux.services.networking.iwd.enable
        then {
          enable = true;
          networks.${cfg.ssid}.pskRaw = "ext:psk";
          secretsFile = cfg.pskFile;
        }
        else {};

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
        anyInterface = true;
      };

      networks."11-lan" = {
        name = "wl*";

        networkConfig =
          (
            if dhcp_enabled
            then {DHCP = "yes";}
            else {
              Address = cfg.static.ip;
              Gateway = cfg.static.gateway;
              DHCP = "no";
              # DNS is managed by systemd-resolved (not specified here)
            }
          )
          // {
            LinkLocalAddressing = "no";
          };

        dhcpV4Config.UseDNS = "no";
        dhcpV6Config.UseDNS = "no";
      };
    };
  }
