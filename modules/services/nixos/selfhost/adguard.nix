{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.selfhost.adguard;

  # tailscale constants (should be configured elsewhere)
  tailscaleIP = "100.69.180.89";
in
  lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.adguardhome = {
        enable = true;
        port = 8001;
        mutableSettings = true;
        settings = {
          http = {
            pprof.enabled = false;
            address = "localhost:${toString config.services.adguardhome.port}";
          };
          users = []; # disable auth (only accessable over tailscale anyway)
          dns = {
            bind_hosts =
              [
                "127.0.0.1"
              ]
              ++ lib.optional config.collinux.services.networking.tailscale.enable tailscaleIP;
            upstream_dns = [
              "https://dns.quad9.net/dns-query"
            ];
            enable_dnssec = true;
          };
          tls.enabled = false;
          dhcp.enabled = false;
        };
      };

      # tailscale stuff
      # disable systemd-resolved (https://github.com/AdguardTeam/AdGuardHome/wiki/FAQ#bindinuse)
      services.resolved.extraConfig = lib.mkIf config.services.resolved.enable ''
        DNS=127.0.0.1
        DNSStubListener=no
      '';
    }
    (lib.mkIf config.collinux.services.networking.tailscale.enable {
      services.tailscale.extraSetFlags = ["--accept-dns=false"]; # would create an infinite loop of dns lookups
      services.caddy = lib.mkIf config.collinux.services.selfhost.caddy.enable {
        virtualHosts."https://adguard.tail7cca06.ts.net".extraConfig = ''
          bind tailscale/adguard
          reverse_proxy ${config.services.adguardhome.settings.http.address}
        '';
      };
    })
  ])
