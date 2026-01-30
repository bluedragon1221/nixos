{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.desktop.wm.components.dunst;

  settings = with config.collinux.palette; ''
    [global]
      frame_color = "#ffffff00"
      separator_color = frame

      highlight = "#${base13}"

      font = "Iosevka Nerd Font"
      offset = "(8,8)"
      origin = "top-right"

    [urgency_low]
      foreground = "#${base05}ff"
      background = "#ffffff00"

    [urgency_normal]
      foreground = "#${base05}ff"
      background = "#ffffff00"

    [urgency_critical]
      foreground = "#${base08}ff"
      background = "#ffffff00"
  '';
in
  lib.mkIf cfg.enable {
    files.".config/dunst/dunstrc".text = settings;
    packages = with pkgs; [dunst inotify-tools];
  }
