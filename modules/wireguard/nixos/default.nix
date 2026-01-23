{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.wireguard;
in
  lib.mkIf cfg.enable {
    networking.firewall.checkReversePath = "loose";

    networking.useNetworkd = true;
    systemd.network = {
      enable = true;

      netdevs."10-wg" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };

        wireguardConfig = {
          PrivateKeyFile = cfg.privateKeyFile;
          ListenPort = 51820;
        };

        wireguardPeers =
          cfg.peers
          |> builtins.mapAttrs (_: m:
            {
              PublicKey = m.publicKey;
              AllowedIPs = [m.ip];
              PersistentKeepalive = 25;
            }
            // (lib.optionalAttrs (m.endpoint != null) {
              Endpoint = m.endpoint;
            }))
          |> builtins.attrValues;
      };

      networks."12-wireguard" = {
        name = "wg0";

        networkConfig = {
          Address = cfg.ip;
          DHCP = "no";
          Gateway = cfg.gateway;
        };
      };
    };
  }
