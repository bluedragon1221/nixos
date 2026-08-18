{
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    package = lib.mkForce (pkgs.caddy.withPlugins {
      plugins = [
        "github.com/tailscale/caddy-tailscale@v0.0.0-20251204171825-f070d146dd61"
        "github.com/caddy-dns/porkbun@v0.3.1"
      ];
      hash = "sha256-3BRyQ/fqPUemW1KqwyvkO1LeZB7PyBMIL/5a2u1mqqU=";
    });

    globalConfig = ''
      acme_dns porkbun {
        api_key {env.PORKBUN_API_KEY}
        api_secret_key {env.PORKBUN_API_SECRET_KEY}
      }
    '';

    virtualHosts = {
      "lindsey.williamsfam.us.com".extraConfig = ''
        redir https://williams-ryan-lindsey.blogspot.com permanent
      '';

      "daniel.williamsfam.us.com".extraConfig = ''
        root * /media/public/www/daniel
        file_server
      '';

      "williamsfam.us.com".extraConfig = ''
        root * /media/public/www/root
        file_server
      '';
    };
  };

  # merge logs from subdomains
  services.caddy.virtualHosts."jta.williamsfam.us.com".logFormat = lib.mkForce ''
    output file /var/log/caddy/access-williamsfam.us.com.log
  '';

  collinux.services.glance.homelabServices."website" = {
    url = "https://williamsfam.us.com";
    icon = "mdi:web";
  };
}
