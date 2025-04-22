{pkgs, ...}: {
  catppuccin.hyprland.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # conflicts with uwsm

    settings = {
      xwayland.enabled = false; # all of my apps are compatible with wayland
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
      ];
      general = {
        "col.active_border" = "$accent";
        "col.inactive_border" = "$base";
        border_size = 2;
        gaps_in = 5;
        gaps_out = 8;
      };
      bind = [
        "Mod4, q, killactive"
        "Mod4, x, exec, ${pkgs.foot}/bin/footclient"
        "Mod4, b, exec, ${pkgs.firefox}/bin/firefox"
        "Mod4, h, exec, ${pkgs.obsidian}/bin/obsidian"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "Mod4, code:1${toString i}, workspace, ${toString ws}"
              "Mod4 SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

      
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 5%-"
      ];

      bindm = [
        "Mod4, mouse:272, movewindow"
        "Mod4, mouse:273, resizewindow"
      ];
      
      monitor = ", prefred, auto, 1"; 
      animations = {
        bezier = [
          "ease, 0.25, 0.1, 0.25, 1"
          "menu_decel, 0.1, 1, 0, 1"
        ];
        animation = [
          "workspaces, 1, 2, ease"
          "workspaces, 1, 7, menu_decel, slidefade 15%"
          "global, 1, 2.5, ease"
          "windowsIn, 1, 2.75, ease, slide"
          "windowsOut, 1.275, ease, slide"
        ];
      };
      misc.disable_hyprland_logo = true;
    };
  };

  home.file."wallpaper" = {
    source = ../wallpaper.jpg;
    target = "Pictures/wallpaper.jpg";
  };
  
  services.hyprpaper = {
    enable = true;
    settings = let
      w = "~/Pictures/wallpaper.jpg";
    in {
      ipc = false;
      preload = [w];

      wallpaper = [
        ",${w}"
      ];
    };
  };
}
