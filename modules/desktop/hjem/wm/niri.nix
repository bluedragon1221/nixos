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

        keyboard {
          xkb {
            options "caps:none"
          }
        }
      }

      hotkey-overlay {
          skip-at-startup
          hide-not-bound
      }

      binds {
        Mod+Space repeat=false { spawn "fuzzel"; }
        Mod+Return repeat=false { spawn "foot"; }
        Mod+B repeat=false { spawn "firefox"; }

        Mod+Q repeat=false { close-window; }
        Mod+S repeat=false { screenshot; }
        Mod+M repeat=false { maximize-column; }

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
          left 0
          right 0
          top 0
          bottom 0
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
