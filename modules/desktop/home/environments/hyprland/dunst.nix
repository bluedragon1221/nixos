{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.hyprland.components.dunst;
in
  lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = lib.mkMerge [
        {
          global = {
            offset = "8x30";
            origin = "top-right";
            transparency = 10;
            font = "Iosevka Nerd Font";
          };
        }
        (lib.mkIf (cfg.theme == "catppuccin") {
          global = {
            frame_color = "#89b4fa";
            highlight = "#89b4fa";
          };

          urgency_low = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
          };

          urgency_normal = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
          };

          urgency_critical = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
            frame_color = "#fab387";
          };
        })
      ];
    };
  }
