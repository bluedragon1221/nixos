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
      hash = "sha256-RM7yd4LV2r6Z4CjwZdzPND28bYbPwfzNMIxZwiYHOsM=";
    });

    globalConfig = ''
      acme_dns porkbun {
        api_key {env.PORKBUN_API_KEY}
        api_secret_key {env.PORKBUN_API_SECRET_KEY}
      }
    '';

    virtualHosts."williamsfam.us.com".extraConfig = ''
      root * /media/public/www
      file_server
    '';
  };
}
