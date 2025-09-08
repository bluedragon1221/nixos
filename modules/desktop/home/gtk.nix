{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.gtk;
in
  lib.mkIf (cfg.enable && cfg.theme == "adwaita") {
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
