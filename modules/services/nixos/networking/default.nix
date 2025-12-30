{
  imports = [
    ./iwd.nix
    ./networkmanager.nix
    ./networkd.nix
  ];

  # DNS
  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
    domains = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  networking.resolvconf.enable = false;

  systemd.network.wait-online.enable = false;
}
