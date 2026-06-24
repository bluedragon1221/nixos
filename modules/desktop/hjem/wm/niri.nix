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
      spawn-at-startup "noctalia-shell"

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

        XF86MonBrightnessUp { spawn-sh "noctalia-shell ipc call brightness increase"; }
        XF86MonBrightnessDown { spawn-sh "noctalia-shell ipc call brightness decrease"; }
        XF86AudioRaiseVolume { spawn-sh "noctalia-shell ipc call volume increase"; }
        XF86AudioLowerVolume { spawn-sh "noctalia-shell ipc call volume decrease"; }
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

        struts {
          left 0
          right 0
          top 0
          bottom 0
        }

        border {
          width 2
          active-color "#89b4faff"
          inactive-color "#ffffff00"
        }

        background-color "transparent"
      }

      blur {
        on
      }

      layer-rule {
          match namespace="^wallpaper$"
          place-within-backdrop true
      }

      window-rule {
        match app-id="firefox"
        open-maximized true
      }

      window-rule {
        match app-id="foot"
        background-effect {
          blur true
        }
      }
    '';

    packages = [pkgs.niri pkgs.xwayland-satellite];
  }
