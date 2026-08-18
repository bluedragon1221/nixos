{
  config,
  hosts,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.wireguard-tools];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall = {
    allowedUDPPorts = [51820];
    allowedTCPPorts = [51843];

    trustedInterfaces = ["wg0"];
  };

  systemd.services.udp2raw-server = {
    description = "udp2raw WireGuard transport";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.udp2raw} -s -l 0.0.0.0:51843 -r 127.0.0.1:51820 -k shared-secret -a";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  systemd.network.netdevs."50-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
      MTUBytes = 1200;
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
