{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.wireguard;
in
  lib.mkIf cfg.enable {
    boot.extraModulePackages = [config.boot.kernelPackages.wireguard];
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.useNetworkd = true;
    systemd.network = {
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
          builtins.map (m: {
            PublicKey = m.publicKey;
            AllowedIPs = [m.ip];
            Endpoint = m.endpoint;
          })
          cfg.peers;
      };

      networks."12-wireguard" = {
        name = "wg0";

        networkConfig = {
          Address = cfg.ip;
          DHCP = "no";
          Gateway = cfg.gateway;

          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
          IPv6AcceptRA = false;
        };
      };
    };
  }
