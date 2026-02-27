{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./minecraft.nix

    ./iwlwifi.nix
    ./caddy.nix
  ];

  # services.tailscale.extraSetFlags = ["--advertise-exit-node"];

  # backup usb teather configuration
  systemd.network.networks."80-usb-teather" = {
    name = "enp0s20f0u2";
    networkConfig.DHCP = "yes";
  };

  systemd.services."disable-wifi-powersave" = {
    description = "Disable wifi powersaving using iw";
    after = ["network.target"];
    serviceConfig.ExecStart = "${pkgs.iw}/bin/iw dev wlp108s0 set power_save off";
    wantedBy = ["default.target"];
  };

  # VPN to server
  systemd.network = {
    netdevs."10-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = config.collinux.secrets."wireguard-pk".path;
        ListenPort = 51820;
      };
      wireguardPeers = [
        {
          PublicKey = "seOq75FUGb+KThvOXCEAGdabWbb+jTRUntITpuAPgWA=";
          AllowedIPs = "0.0.0.0/0";
          Endpoint = "20.251.8.247:51820";
          PersistentKeepalive = 25;
        }
      ];
    };
    networks."wg0" = {
      matchConfig.Name = "wg0";
      address = ["10.100.0.2/24"];
      DHCP = "no";
      networkConfig.IPv6AcceptRA = false;
    };
  };

  # kill-switch for qbittorrent traffic
  networking.firewall.extraCommands =
    # bash
    ''
      # Allow qbittorrent traffic over wg0
      iptables -A OUTPUT -o wg0 -m owner --uid-owner qbittorrent -j ACCEPT

      # Drop qbittorrent traffic over anything else
      iptables -A OUTPUT ! -o wg0 -m owner --uid-owner qbittorrent -j REJECT
    '';

  services.fail2ban.enable = true;

  # merge logs from subdomains
  services.caddy.virtualHosts."up.williamsfam.us.com".logFormat = lib.mkForce ''
    output file /var/log/caddy/access-williamsfam.us.com.log
  '';

  # i broke something and this fixes it
  environment.etc."systemd/resolved.conf.d/10-dns.conf".text = config.environment.etc."systemd/resolved.conf".text;
}
