{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.greetd;
in
  lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = cfg.command;
          user = config.collinux.user.name;
        };
        default_session = initial_session;
      };
    };
  }
