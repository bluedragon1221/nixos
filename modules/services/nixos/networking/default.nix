{
  imports = [
    ./iwd.nix
    ./networkmanager.nix
    ./networkd.nix
  ];

  # DNS
  services.resolved = {
    enable = true;
    llmnr = "false";
    dnsovertls = "opportunistic";
    fallbackDns = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
    extraConfig = ''
      MulticastDNS=no
    '';
  };
  networking.resolvconf.enable = false;

  systemd.network.wait-online.enable = false;
}
