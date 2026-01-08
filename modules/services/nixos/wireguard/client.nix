{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.networking.wireguard;
in
  lib.mkIf (cfg.enable && cfg.localPeer.role == "spoke") {
    boot.extraModulePackages = [config.boot.kernelPackages.wireguard];

    # we know the machine is configured to use networkd already
    systemd.network = {
      netdevs = {
        "10-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
          };

          wireguardConfig = {
            PrivateKeyFile = cfg.privateKeyFile;
            ListenPort = 51820;
          };

          wireguardPeers = [
            {
              PublicKey = ""; # will configure later
              AllowedIPs = ["100.100.0.1"];
              Endpoint = "williamsfam.us.com:51820"; # not configured yet
            }
          ];
        };
      };

      networks."12-wireguard" = {
        name = "wg0";

        networkConfig = {
          Address = cfg.ip;
          Gateway = "100.100.0.1";
          DHCP = "no";

          # disable ipv6 addresses
          IPv6AcceptRA = "no";
          IPv6PrivacyExtensions = "no";
          LinkLocalAddressing = "no";
        };
      };
    };
  }
