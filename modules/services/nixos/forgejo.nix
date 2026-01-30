{
  lib,
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
          DOMAIN = "localhost";
          ROOT_URL = cfg.root_url;
          HTTP_PORT = cfg.port;

          # ssh
          START_SSH_SERVER = true; # use builtin ssh server
          BUILTIN_SSH_SERVER_USER = "git";
          SSH_DOMAIN = cfg.root_url or "ganymede";
          SSH_PORT = cfg.git_ssh_port; # don't conflict with system ssh
          SSH_LISTEN_HOST = cfg.bind_host;
          SSH_LISTEN_PORT = cfg.git_ssh_port;
        };
        service = {
          DISABLE_REGISTRATION = false;
          ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        };
        repository = {
          # disable stuff
          DISABLE_MIGRATIONS = true;
          DISABLE_STARS = true;
          DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
        };
      };
    };

    systemd.services."forgejo" = lib.mkIf config.collinux.services.networking.networkd.enable {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];
    };
  };
}
