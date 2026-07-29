{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.system.network.dns;
in
  lib.mkIf (!cfg.areYouAServer) {
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
