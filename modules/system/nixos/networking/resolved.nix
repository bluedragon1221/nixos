{
  networking.resolvconf.enable = false;

  networking.nameservers = [
    "9.9.9.9#dns.quad9.net"
    "149.112.112.112#dns.quad9.net"
  ];

  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
    dnssec = "allow-downgrade";

    # disable extra stuff
    llmnr = "false";
    extraConfig = "MulticastDNS=no";
  };
}
