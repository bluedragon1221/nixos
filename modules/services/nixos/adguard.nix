{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.adguard;
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      port = cfg.port;
      mutableSettings = true;
      settings = {
        http = {
          pprof.enabled = false;
          address = "localhost:${toString cfg.port}";
        };
        users = []; # disable auth (only accessable over tailscale anyway)
        dns = {
          bind_hosts = ["127.0.0.1" cfg.bind_host];
          upstream_dns = ["https://dns.quad9.net/dns-query"];
          enable_dnssec = true;
        };
        tls.enabled = false;
        dhcp.enabled = false;
      };
    };

    # disable systemd-resolved (https://github.com/AdguardTeam/AdGuardHome/wiki/FAQ#bindinuse)
    services.resolved.extraConfig = lib.mkIf config.services.resolved.enable ''
      DNS=127.0.0.1
      DNSStubListener=no
    '';
    services.tailscale.extraSetFlags = lib.optional config.collinux.services.networking.tailscale.enable "--accept-dns=false"; # would create an infinite loop of dns lookups
  };
}
