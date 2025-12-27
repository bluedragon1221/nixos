{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.gtk;
in
  lib.mkIf cfg.enable {
    packages = with pkgs; [
      dconf

      cfg.cursor_data.package
      cfg.theme_data.package
    ];

    xdg.config.files =
      {
        "gtk-3.0/settings.ini" = {
          generator = lib.generators.toINI {};
          value.Settings = {
            gtk-cursor-theme-name = cfg.cursor_data.name;
            gtk-cursor-theme-size = 24;
            gtk-theme-name = cfg.theme_data.name;
          };
        };
        "gtk-4.0/settings.ini" = {
          generator = lib.generators.toINI {};
          value.Settings = {
            gtk-cursor-theme-name = cfg.cursor_data.name;
            gtk-cursor-theme-size = 24;
            gtk-theme-name = lib.mkIf (cfg.theme_data.name != "adw-gtk3") cfg.theme_data.name;
          };
        };
      }
      // lib.optionalAttrs (cfg.theme == "catppuccin") {
        "gtk-4.0/gtk.css".text = ''
          @import url("file://${cfg.theme_data.package}/share/themes/catppuccin-mocha-blue-standard/gtk-4.0/gtk.css");
        '';
      };
  }
