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
      user = config.collinux.user.name;
      command = with config.collinux.desktop;
        if (wm.sway.enable && !gnome.enable && !wm.niri.enable)
        then lib.getExe pkgs.sway
        else if (wm.niri.enable && !gnome.enable && !wm.sway.enable)
        then "${pkgs.niri}/bin/niri-session"
        else null;
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
