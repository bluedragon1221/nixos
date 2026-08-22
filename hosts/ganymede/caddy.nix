{
  pkgs,
  lib,
  hosts,
  config,
  ...
}: {
  users.users."caddy".extraGroups = ["fileserver"];

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

      pki {
        ca local {
          name "Ganymede Home CA"

          root {
              format pem_file
              cert ${pkgs.writeText "caddy-root-ca.crt" hosts.ganymede.caddy-root-ca}
              key ${config.collinux.secrets.caddy-root-ca-key.path}
          }
        }
      }
    '';

    virtualHosts = {
      "jta.williamsfam.us.com" = {
        logFormat = lib.mkForce ''
          output file /var/log/caddy/access-williamsfam.us.com.log
        '';
        extraConfig = ''
          root * /media/public/www/jta

          @hidden path */.*
          respond @hidden "Not Found" 404

          file_server
        '';
      };
      "lindsey.williamsfam.us.com" = {
        logFormat = lib.mkForce ''
          output file /var/log/caddy/access-williamsfam.us.com.log
        '';
        extraConfig = ''
          redir https://williams-ryan-lindsey.blogspot.com permanent
        '';
      };
      "daniel.williamsfam.us.com" = {
        logFormat = lib.mkForce ''
          output file /var/log/caddy/access-williamsfam.us.com.log
        '';
        extraConfig = ''
          root * /media/public/www/daniel
          file_server
        '';
      };
      "williamsfam.us.com" = {
        logFormat = lib.mkForce ''
          output file /var/log/caddy/access-williamsfam.us.com.log
        '';
        extraConfig = ''
          root * /media/public/www/root
          file_server
        '';
      };
    };
  };

  collinux.services.glance.homelabServices."website" = {
    url = "https://williamsfam.us.com";
    icon = "mdi:web";
  };
}
