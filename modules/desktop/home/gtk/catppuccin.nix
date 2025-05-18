{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.gtk;
in
  lib.mkIf (cfg.theme == "catppuccin") {
    home.pointerCursor = {
      hyprcursor = {
        enable = true;
        size = 24;
      };
      gtk.enable = true;
      dotIcons.enable = false;

      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };

    gtk = {
      theme = {
        package = pkgs.catppuccin-gtk.override {
          accents = ["blue"];
          variant = "mocha";
          size = "standard";
        };
        name = "catppuccin-mocha-blue-standard";
      };
    };
  }
