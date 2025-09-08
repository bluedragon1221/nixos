{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.gtk;
in {
  packages = with pkgs; [
    dconf

    papirus-icon-theme
    cfg.cursor_data.package
    cfg.theme_data.package
  ];

  xdg.config.files = let
    value.Settings = {
      gtk-cursor-theme-name = cfg.cursor_data.name;
      gtk-cursor-size = 24;
      gtk-icon-theme-name = "Papirus";
      gtk-theme-name = cfg.theme_data.name;
    };
  in {
    "gtk-3.0/settings.ini" = {
      generator = lib.generators.toINI {};
      inherit value;
    };
    "gtk-4.0/settings.ini" = {
      generator = lib.generators.toINI {};
      inherit value;
    };
    "gtk-4.0/gtk.css".text = ''
      @import url("file://${cfg.theme_data.package}/gtk-4.0/gtk.css");
    '';
  };
}
