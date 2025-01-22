{
  cfgWrapper,
  inputs',
  pkgs,
  my-mako,
  my-waybar,
  my-fuzzel,
  my-firefox,
  my-kitty,
  my-foot,
  my-music,
}: let
  hyprshot = cfgWrapper {
    pkg = pkgs.hyprshot;
    extraEnv.HYPRSHOT_DIR = "Pictures/hyprshot";
  };

  settings = pkgs.writeText "hyprland.conf" ''
    exec-once=${my-mako}/bin/mako
    exec-once=${my-waybar}/bin/waybar
    exec-once=${pkgs.swaybg}/bin/swaybg -i ${./wallpaper.jpg}

    env=XCURSOR_PATH,${pkgs.vanilla-dmz}/share/icons
    env=XCURSOR_THEME,Vanilla-DMZ
    env=XCURSOR_SIZE,24
    env=HYPRCURSOR_THEME,24
    exec-once=dconf write /org/gnome/desktop/interface/cursor-theme "'Vanilla-DMZ'"

    env=QT_QPA_PLATFORM,wayland;xcb # fallback to x11 if wayland isn't available
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
    }

    general {
      layout=dwindle
      border_size=2
      col.active_border=rgba(c6a0f6ff)
      col.inactive_border=rgba(24273Aff)
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

    input {
      kb_options=caps:enter
      touchpad:disable_while_typing=false
    }

    bind=Mod4, x, exec, ${my-foot}/bin/foot
    bind=Mod4 SHIFT, x, exec, ${my-kitty}/bin/kitty
    bind=Mod4, SPACE, exec, ${my-fuzzel}/bin/fuzzel
    bind=Mod4, b, exec, ${my-firefox}/bin/firefox
    bind=Mod4, m, exec, ${my-music}/bin/kitty-music
    bind=Mod4 SHIFT, b, exec, ${inputs'.zen-browser.packages."x86_64-linux".default}/bin/zen

    bind=Mod4, q, killactive
    bind=Mod4 SHIFT, q, exit

    bind=Mod4 SHIFT, s, exec, ${hyprshot}/bin/hyprshot -m region
    bind=, Print, exec, ${my-music}/bin/cmus-remote -u
    bind=Mod4, ., exec, ${my-mako}/bin/makoctl dismiss -a

    ${builtins.concatStringsSep "\n" (builtins.genList (
        i: let
          s = toString i;
        in ''
          bind=Mod4, ${s}, workspace, ${s}
          bind=Mod4 SHIFT, ${s}, movetoworkspace, ${s}
        ''
      )
      9)}

    binde=, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    binde=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

    binde=, XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 5%+
    binde=, XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 5%-

    bindm=Mod4, mouse:272, movewindow
    bindm=Mod4, mouse:273, resizewindow

    # fix scaling issues
    monitor=, preferred, auto, 1
  '';
in
  cfgWrapper {
    pkg = pkgs.hyprland;
    extraFlags = ["-c ${settings}"];
  }
