{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.gtk;
in
  lib.mkIf (cfg.theme == "adwaita") {
    home.pointerCursor = {
      gtk.enable = true;
      dotIcons.enable = false;

      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };

    gtk.theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };

    home.packages = with pkgs.gnomeExtensions; [
      blur-my-shell
    ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };
      };
    };
  }
