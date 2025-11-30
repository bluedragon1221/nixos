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
      background = "#${base00}99"
      foreground = "#${base05}ff"

    [urgency_normal]
      background = "#${base00}99"
      foreground = "#${base05}ff"

    [urgency_critical]
      background = "#${base00}99"
      foreground = "#${base05}ff"
      frame_color = "#${base08}"
  '';
in
  lib.mkIf cfg.enable {
    files.".config/dunst/dunstrc".text = settings;
    packages = with pkgs; [dunst inotify-tools];
  }
