{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.selfhost.forgejo;
in
  lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database.type = "postgres";
      settings = {
        server = {
          DOMAIN = "localhost";
          HTTP_PORT = 8010;
        };
        service.DISABLE_REGISTRATION = false;
      };
    };
  }
