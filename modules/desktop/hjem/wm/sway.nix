{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.wm.sway;

  batteryNotify = pkgs.writeShellApplication {
    name = "battery-notify";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libnotify
    ];
    text = ''
      energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
      energy_full=$(cat /sys/class/power_supply/BAT0/energy_full)
      percentage=$((energy_now * 100 / energy_full))
      percent_display=$(printf "%.0f%%" "$percentage")

      notify-send \
        -t 2000 \
        -h int:value:"$percentage" \
        -h string:x-dunst-stack-tag:battery \
        "Battery" \
        "$percent_display"
    '';
  };

  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [
      pkgs.fuzzel
      pkgs.systemd
      pkgs.sway
    ];
    text = ''
      selection=$(printf '%s\n' logout suspend reboot shutdown | fuzzel --dmenu --prompt "power: ")

      case "$selection" in
        logout)
          swaymsg exit
          ;;
        suspend)
          systemctl suspend
          ;;
        reboot)
          systemctl reboot
          ;;
        shutdown)
          systemctl poweroff
          ;;
      esac
    '';
  };

  settings = with config.collinux.palette; ''
    exec {
      ${config.collinux.desktop.wallpaper_cmd}
      ${pkgs.dunst}/bin/dunst
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP GTK_USE_PORTAL NIXOS_OZONE_WL MOZ_ENABLE_WAYLAND
    }

    # target                 title      bg         text       indicator  border
    client.focused           #${base07} #${base00} #${base05} #${base06} #${base13}
    client.focused_inactive  #${base03} #${base00} #${base05} #${base06} #${base03}
    client.unfocused         #${base03} #${base00} #${base05} #${base06} #${base03}
    client.urgent            #${base09} #${base00} #${base09} #${base03} #${base09}
    client.placeholder       #${base03} #${base00} #${base05} #${base03} #${base03}
    client.background        #${base00}

    input {
      type:keyboard xkb_options caps:none
      type:touchpad dwt disabled
    }

    default_border pixel 2
    default_floating_border pixel 2
    smart_borders on
    smart_gaps on

    floating_modifier Mod4 normal
    default_orientation auto

    bindsym {
      Mod4+1 workspace number 1
      Mod4+2 workspace number 2
      Mod4+3 workspace number 3
      Mod4+4 workspace number 4
      Mod4+5 workspace number 5
      Mod4+6 workspace number 6
      Mod4+7 workspace number 7
      Mod4+8 workspace number 8
      Mod4+9 workspace number 9

      Mod4+Shift+1 move container to workspace number 1
      Mod4+Shift+2 move container to workspace number 2
      Mod4+Shift+3 move container to workspace number 3
      Mod4+Shift+4 move container to workspace number 4
      Mod4+Shift+5 move container to workspace number 5
      Mod4+Shift+6 move container to workspace number 6
      Mod4+Shift+7 move container to workspace number 7
      Mod4+Shift+8 move container to workspace number 8
      Mod4+Shift+9 move container to workspace number 9

      Mod4+q kill

      Mod4+Return   exec foot
      Mod4+Space    exec fuzzel
      Mod4+Escape   exec '${powerMenu}/bin/power-menu'
      Mod4+b        exec firefox
      Mod4+k        exec '${batteryNotify}/bin/battery-notify'
      Mod4+w        exec '${pkgs.iwmenu}/bin/iwmenu -l fuzzel -i font -s 2'
      Mod4+e        exec '${pkgs.bzmenu}/bin/bzmenu -l fuzzel -i font -s 2'

      Mod4+Shift+s  exec '${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Pictures/$(date +"%s_grim.png")'
      Mod4+Alt+s    exec '${pkgs.hyprpicker}/bin/hyprpicker'

      Home                  exec 'util.lua music prev'
      End                   exec 'util.lua music toggle'
      Insert                exec 'util.lua music next'
      XF86AudioRaiseVolume  exec 'util.lua volume up'
      XF86AudioLowerVolume  exec 'util.lua volume down'
      XF86MonBrightnessUp   exec 'util.lua brightness up'
      XF86MonBrightnessDown exec 'util.lua brightness down'
    }
  '';
in
  lib.mkIf cfg.enable {
    files.".config/sway/config".text = settings;

    packages = with pkgs; [
      sway
      wl-clipboard
    ];
  }
