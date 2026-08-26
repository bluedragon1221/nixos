{
  config,
  hosts,
  pkgs,
  lib,
  ...
}: let
  wg-mode = pkgs.writeShellScriptBin "wg-mode" ''
    PEER_KEY="${hosts.ganymede.wg_pubkey}"
    IFACE="wg0"
    case "$1" in
      full)
        sudo bash -c "
          wg set '$IFACE' peer '$PEER_KEY' allowed-ips 0.0.0.0/0,::/0
          ip route add default dev '$IFACE' metric 100
        "
        echo "Switched $IFACE to Full Tunnel"
        ;;
      split)
        sudo bash -c "
          ip route del default dev '$IFACE' metric 100
          wg set '$IFACE' peer '$PEER_KEY' allowed-ips 10.0.0.0/24
        "
        echo "Switched $IFACE to Split Tunnel"
        ;;
      *)
        echo "Usage: wg-mode [full|split]"
        exit 1
        ;;
    esac
  '';
in {
  environment.systemPackages = [
    pkgs.wireguard-tools
    wg-mode
  ];

  systemd.services.udp2raw-client = {
    description = "udp2raw WireGuard transport";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.udp2raw} -c -l 127.0.0.1:51820 -r 104.53.197.192:51843 -k shared-secret -a";
      Restart = "on-failure";
    };
  };

  systemd.network.netdevs."10-wg" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
      MTUBytes = "1200";
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
