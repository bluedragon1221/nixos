{
  networking.resolvconf.enable = false;

  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
    dnssec = "allow-downgrade";
    fallbackDns = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    # disable extra stuff
    llmnr = "false";
    extraConfig = "MulticastDNS=no";
  };
}
