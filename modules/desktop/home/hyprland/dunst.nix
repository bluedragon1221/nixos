{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.hyprland;
in
  lib.mkIf (cfg.enable && cfg.components.dunst.enable) {
    catppuccin.dunst.enable = true;
    services.dunst = {
      enable = true;
      settings = {
        global = {
          offset = "8x30";
          origin = "top-right";
          transparency = 10;
          font = "Iosevka Nerd Font";
        };
      };
    };
  }
