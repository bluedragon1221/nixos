{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.wm.niri;
in
  lib.mkIf cfg.enable {
    files.".config/niri/config.kdl".text = ''
      spawn-sh-at-startup "${config.collinux.desktop.wallpaper_cmd}"
      spawn-at-startup "${pkgs.playerctl}/bin/playerctld daemon"
      spawn-at-startup "dunst"

      prefer-no-csd
      environment {
        GTK_CSD "1"
      }

      output "eDP-1" {
        scale 1.0
      }

      input {
        focus-follows-mouse
      }

      hotkey-overlay {
          skip-at-startup
          hide-not-bound
      }

      binds {
        Mod+Q { close-window; }

        Mod+Space { spawn "fuzzel"; }
        Mod+Return { spawn "foot"; }
        Mod+B { spawn "firefox"; }

        Mod+m { maximize-column; }

        XF86MonBrightnessUp { spawn "~/.config/util.lua" "brightness" "5%+"; }
        XF86MonBrightnessDown { spawn "~/.config/util.lua" "brightness" "5%-"; }
        XF86AudioRaiseVolume { spawn "~/.config/util.lua" "vol" "5%+"; }
        XF86AudioLowerVolume { spawn "~/.config/util.lua" "vol" "5%-"; }
      }

      gestures {
        hot-corners {
          off
        }
      }

      overview {
        zoom 0.66
        workspace-shadow {
          off
        }
      }

      layout {
        gaps 12

        focus-ring {
          off
        }

        border {
          width 3
          active-color "#ffffff00"
          inactive-color "#ffffff00"
          urgent-color "#ffffff00"
        }

        struts {
          left 16
          right 16
          top 16
          bottom 16
        }

        background-color "transparent"
      }

      layer-rule {
          match namespace="^wallpaper$"
          place-within-backdrop true
      }

      layer-rule {
        match namespace="^launcher$"
        shadow {
          on
        }
      }

      layer-rule {
        match namespace="^notifications$"
        shadow {
          on
        }
      }

      window-rule {
        match app-id="firefox"
        open-maximized true
      }

      window-rule {
        match is-focused=true
        shadow {
          on
        }
      }

    '';

    packages = [pkgs.niri pkgs.xwayland-satellite];
  }
