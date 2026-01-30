{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.greetd;

  session =
    if cfg.cosmic-greeter.enable
    then {
      command = "${pkgs.cosmic-greeter}/bin/cosmic-greeter-start";
      user = config.collinux.user.name;
    }
    else if cfg.autologin.enable
    then {
      command = cfg.autologin.command;
      user = config.collinux.user.name;
    }
    else {};
in
  lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        initial_session = session;
        default_session = session;
      };
    };
  }
