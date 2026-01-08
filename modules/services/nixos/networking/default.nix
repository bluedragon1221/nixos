{
  imports = [
    ./iwd.nix
    ./networkmanager.nix
    ./networkd.nix
  ];

  networking.firewall.enable = true;

  # DNS
  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
    fallbackDns = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    # disable extra stuff
    llmnr = "false";
    extraConfig = "MulticastDNS=no";
  };
  networking.resolvconf.enable = false;

  systemd.network.wait-online.enable = false;
}
