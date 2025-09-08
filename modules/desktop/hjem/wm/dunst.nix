{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.desktop.sway.components.dunst;

  settings = ''
    [global]
      frame_color = "#89b4fa"
      separator_color = frame
      highlight = "#89b4fa"
      offset = "(8,8)"
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
    files.".config/dunst/dunstrc".text = settings;
    packages = with pkgs; [dunst inotify-tools];
  }
