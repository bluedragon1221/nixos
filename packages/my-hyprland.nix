{
  cfgWrapper,
  pkgs,
  my-mako,
  my-waybar,
  my-cmus,
  my-fuzzel,
  my-firefox,
  my-kitty,
  kitty-music,
}: let
  wallpapers = builtins.fetchGit {
    url = "https://github.com/bluedragon1221/wallpapers";
    rev = "24dfb80741381c9c240f108b796e3d8f4896f04d";
  };

  settings = pkgs.writeText "hyprland.conf" ''
    exec-once=${my-mako}/bin/mako
    exec-once=${my-waybar}/bin/waybar
    exec-once=${pkgs.swaybg}/bin/swaybg -i ${wallpapers}/wallpaper_legal.png

    env=XCURSOR_PATH,${pkgs.vanilla-dmz}/share/icons
    env=XCURSOR_THEME,Vanilla-DMZ

    env=HYPRSHOT_DIR,Pictures/hyprshot

    env=QT_QPA_PLATFORM,wayland
    env=ELECTRON_OZONE_PLATFORM_HINT,wayland

    animations {
      bezier=ease,.25,.1,.25,1
      bezier = menu_decel, 0.1, 1, 0, 1

      # animation=workspaces, 1, 2, ease
      animation=workspaces, 1, 7, menu_decel, slidefade 15%
      animation=global,     1, 2.5, ease
      animation=windowsIn,  1, 2.75, ease, slide
      animation=windowsOut, 1, 2.75, ease, slide
    }

    decoration {
      blur {
        enabled=true
        passes=2
        vibrancy=0.169600
      }

      shadow:enabled=false
      layerrule=dimaround, ^(launcher)
      layerrule=animation popin, ^(launcher)
      layerrule=blur, ^(launcher)
      rounding=0
      windowrule=noblur, ^(?!(kitty))
    }

    general {
      layout=dwindle
      border_size=2
      col.active_border=rgba(c6a0f6ff)
      col.inactive_border=rgba(24273acc)
      gaps_in=5
      gaps_out=8
      resize_on_border=true
    }

    dwindle {
      force_split=2
      pseudotile=true
    }

    misc {
      vfr=true
      disable_hyprland_logo=true
      disable_splash_rendering=true
    }

    bind=Mod4, x, exec, ${my-kitty}/bin/kitty
    bind=Mod4, SPACE, exec, ${my-fuzzel}/bin/fuzzel
    bind=Mod4, b, exec, ${my-firefox}/bin/firefox
    bind=Mod4, m, exec, ${kitty-music}/bin/kitty-music
    bind=Mod4 SHIFT, b, exec, zen

    bind=Mod4, p, pin

    bind=Mod4, q, killactive
    bind=Mod4 SHIFT, q, exit

    bind=Mod4 SHIFT, s, exec, ${pkgs.hyprshot}/bin/hyprshot -m region
    bind=, Print, exec, ${my-cmus}/bin/cmus-remote -u
    bind=Mod4, ., exec, ${my-mako}/bin/makoctl dismiss -a

    bind=Mod4, 0, workspace, 0
    bind=Mod4, 1, workspace, 1
    bind=Mod4, 2, workspace, 2
    bind=Mod4, 3, workspace, 3
    bind=Mod4, 4, workspace, 4
    bind=Mod4, 5, workspace, 5
    bind=Mod4, 6, workspace, 6
    bind=Mod4, 7, workspace, 7
    bind=Mod4, 8, workspace, 8
    bind=Mod4 SHIFT, 0, movetoworkspace, 0
    bind=Mod4 SHIFT, 1, movetoworkspace, 1
    bind=Mod4 SHIFT, 2, movetoworkspace, 2
    bind=Mod4 SHIFT, 3, movetoworkspace, 3
    bind=Mod4 SHIFT, 4, movetoworkspace, 4
    bind=Mod4 SHIFT, 5, movetoworkspace, 5
    bind=Mod4 SHIFT, 6, movetoworkspace, 6
    bind=Mod4 SHIFT, 7, movetoworkspace, 7
    bind=Mod4 SHIFT, 8, movetoworkspace, 8

    binde=, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    binde=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindm=Mod4, mouse:272, movewindow
    bindm=Mod4, mouse:273, resizewindow

    # fix scaling issues
    monitor=, preferred, auto, 1
  '';
in
  cfgWrapper {
    pkg = pkgs.hyprland;
    binName = "Hyprland";
    extraPkgs = [my-waybar];
    extraFlags = ["-c ${settings}"];
  }
