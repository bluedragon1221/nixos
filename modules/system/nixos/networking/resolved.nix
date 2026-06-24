{config, ...}: let
  hostname = config.networking.hostName;
  netname = "${hostname}net0";
in {
  networking.resolvconf.enable = false;

  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5353;
      address = "/.${hostname}/127.0.0.1";
      bind-interfaces = true;
    };
  };

  systemd.network.netdevs."19-localnet" = {
    netdevConfig = {
      Name = netname;
      Kind = "dummy";
    };
  };

  systemd.network.networks."19-localnet" = {
    matchConfig = {
      Name = netname;
    };
    address = ["192.0.2.1/32"]; # BUG(?): a dummy network must have an address for systemd-networkd to attempt to use it to resolve dns queries (that took forever to debug)
    dns = ["127.0.0.1:5353"];
    domains = ["~${hostname}"];
    extraConfig = ''
      LinkLocalAddressing=no
      ConfigureWithoutCarrier=yes
      DNSSEC=no
      DNSOverTLS=no
    '';
  };

  networking.nameservers = [
    "9.9.9.9#dns.quad9.net"
    "149.112.112.112#dns.quad9.net"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSOverTLS = true;
      DNSSEC = "allow-downgrade";

      LLMNR = false;
      MulticastDNS = false;
    };
  };
}
