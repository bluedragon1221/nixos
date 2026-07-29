{
  config,
  hosts,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.wireguard-tools];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall = {
    allowedUDPPorts = [51820];
    trustedInterfaces = ["wg0"]; # bypass firewall inside wireguard
  };

  systemd.network.netdevs."50-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
      MTUBytes = "1300";
    };
    wireguardConfig = {
      PrivateKeyFile = config.collinux.secrets."wireguard-privkey".path;
      ListenPort = 51820;
    };
    wireguardPeers = [
      {
        PublicKey = hosts.mercury.wg_pubkey;
        AllowedIPs = ["${hosts.mercury.wg_ip}/32"];
      }
      {
        PublicKey = hosts.terra.wg_pubkey;
        AllowedIPs = ["${hosts.terra.wg_ip}/32"];
      }
    ];
  };
  systemd.network.networks."wg0" = {
    matchConfig.Name = "wg0";
    address = ["${hosts.ganymede.wg_ip}/24"];
    networkConfig = {
      IPMasquerade = "ipv4";
      IPv4Forwarding = true;
    };
  };
}
