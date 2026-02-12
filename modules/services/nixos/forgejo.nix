{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.collinux.services.forgejo;
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      settings = {
        server = {
          PROTOCOL = "http";
          ROOT_URL = "https://${
            if cfg.publicURL
            then cfg.publicURL
            else if cfg.privateURL
            then cfg.privateURL
            else ""
          }";

          HTTP_ADDR = cfg.listenAddr;
          HTTP_PORT = cfg.port;

          OFFLINE_MODE = true; # don't use cdns or gravatar

          # ssh
          START_SSH_SERVER = false; # use system ssh server
          SSH_USER = "forgejo";
          SSH_DOMAIN = "williamsfam.us.com";
          SSH_PORT = 22;
        };
        service = {
          DISABLE_REGISTRATION = true;
          ENABLE_REVERSE_PROXY_AUTHENTICATION = false;
        };
        repository = {
          # disable stuff
          DISABLE_MIGRATIONS = true;
          DISABLE_STARS = true;
          DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
        };
      };
    };

    systemd.services."forgejo" = {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];

      # Ensure users (https://wiki.nixos.org/wiki/Forgejo#Ensure_users)
      preStart = let
        adminCmd = "${lib.getExe pkgs.forgejo} admin user";
        passwd = config.collinux.secrets."collin-forgejo-password";
      in ''
        ${adminCmd} create --admin --email "collin@ganymede" --username collin --password "$(tr -d '\n' < ${passwd.path})" || true
      '';
    };
  };
}
