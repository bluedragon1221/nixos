{
  config,
  hosts,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.wireguard-tools];

  systemd.services.udp2raw-client = {
    description = "udp2raw WireGuard transport";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.udp2raw} -c -l 127.0.0.1:51820 -r 70.130.121.193:51843 -k shared-secret -a";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  systemd.network.netdevs."10-wg" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
      MTUBytes = 1200;
    };
    wireguardConfig = {
      PrivateKeyFile = config.collinux.secrets."wireguard-privkey".path;
      ListenPort = 9918;
    };
    wireguardPeers = [
      {
        PublicKey = hosts.ganymede.wg_pubkey;
        AllowedIPs = ["10.100.0.0/24"];
        Endpoint = "127.0.0.1:51820";
      }
    ];
  };
  systemd.network.networks."wg0" = {
    matchConfig.Name = "wg0";
    address = ["${hosts.mercury.wg_ip}/24"];
    DHCP = "no";
    dns = [hosts.ganymede.wg_ip];
    domains = ["~ganymede"];
    networkConfig.IPv6AcceptRA = false;
    extraConfig = ''
      DNSOverTLS=no
      DNSSEC=no
    '';
  };
}
