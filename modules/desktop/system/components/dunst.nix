{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.desktop.components.dunst;

  settings = ''
    [global]
      frame_color = "#89b4fa"
      separator_color = frame
      highlight = "#89b4fa"
      offset = "8x30"
      origin = "top-right"
      transparency = 10
      font = "Iosevka Nerd Font"

    [urgency_low]
      background = "#1e1e2e"
      foreground = "#cdd6f4"

    [urgency_normal]
      background = "#1e1e2e"
      foreground = "#cdd6f4"

    [urgency_critical]
      background = "#1e1e2e"
      foreground = "#cdd6f4"
      frame_color = "#fab387"
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files.".config/dunst/dunstrc".text = settings;
      packages = [pkgs.dunst pkgs.inotify-tools];
    };
  }
