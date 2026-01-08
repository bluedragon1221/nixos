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
      hash = "sha256-BQdm8p9eDGhRu6mKyX2FAUaKoU6Lv2A746Sey39T13I=";
    });

    extraConfig = ''
      {
        acme_dns porkbun {
          api_key {env.PORKBUN_API_KEY}
          api_secret_key {env.PORKBUN_API_SECRET_KEY}
        }
      }
    '';

    virtualHosts."https://web.tail7cca06.ts.net".extraConfig = ''
      bind tailscale/web
      root * /var/www/williams_web
      file_server

      handle_path /papa_stories/* {
        root * /var/www/papa_stories
        file_server
      }
    '';
  };
}
