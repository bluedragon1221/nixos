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

    catppuccin.gtk.enable = true; # TODO USING THIS MAKES ERRORS ON JUPITER
  }
