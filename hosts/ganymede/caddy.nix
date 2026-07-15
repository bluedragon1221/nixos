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
      hash = "sha256-FrAI7Fpz3bXclmKcizBMv/VI1hTAWT6DQnj7S09MwNY=";
    });

    globalConfig = ''
      acme_dns porkbun {
        api_key {env.PORKBUN_API_KEY}
        api_secret_key {env.PORKBUN_API_SECRET_KEY}
      }
    '';

    virtualHosts."lindsey.williamsfam.us.com".extraConfig = ''
      redir https://williams-ryan-lindsey.blogspot.com permanent
    '';

    virtualHosts."daniel.williamsfam.us.com".extraConfig = ''
      root * /media/public/www/daniel
      file_server
    '';

    # virtualHosts."collin.williamsfam.us.com".extraConfig = ''
    #   root * /med
    # '';

    virtualHosts."williamsfam.us.com".extraConfig = ''
      root * /media/public/www/root
      file_server
    '';
  };
}
