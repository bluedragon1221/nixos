{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.wm.sway;

  colors = ''
    set $rosewater #f5e0dc
    set $flamingo #f2cdcd
    set $pink #f5c2e7
    set $mauve #cba6f7
    set $red #f38ba8
    set $maroon #eba0ac
    set $peach #fab387
    set $yellow #f9e2af
    set $green #a6e3a1
    set $teal #94e2d5
    set $sky #89dceb
    set $sapphire #74c7ec
    set $blue #89b4fa
    set $lavender #b4befe
    set $text #cdd6f4
    set $subtext1 #bac2de
    set $subtext0 #a6adc8
    set $overlay2 #9399b2
    set $overlay1 #7f849c
    set $overlay0 #6c7086
    set $surface2 #585b70
    set $surface1 #45475a
    set $surface0 #313244
    set $base #1e1e2e
    set $mantle #181825
    set $crust #11111b
  '';

  settings = ''
    exec ${config.collinux.desktop.wallpaper_cmd}
    exec ${pkgs.dunst}/bin/dunst
    exec ${pkgs.soteria}/bin/soteria

    include catppuccin-mocha

    # target                 title     bg    text   indicator  border
    client.focused           $lavender $base $text  $rosewater $blue
    client.focused_inactive  $overlay0 $base $text  $rosewater $overlay0
    client.unfocused         $overlay0 $base $text  $rosewater $overlay0
    client.urgent            $peach    $base $peach $overlay0  $peach
    client.placeholder       $overlay0 $base $text  $overlay0  $overlay0
    client.background        $base

    input type:keyboard {
      xkb_options caps:none
    }

    input type:touchpad {
      dwt disabled
    }

    bindsym Mod4+1 workspace number 1
    bindsym Mod4+2 workspace number 2
    bindsym Mod4+3 workspace number 3
    bindsym Mod4+4 workspace number 4
    bindsym Mod4+5 workspace number 5
    bindsym Mod4+6 workspace number 6
    bindsym Mod4+7 workspace number 7
    bindsym Mod4+8 workspace number 8
    bindsym Mod4+9 workspace number 9

    bindsym Mod4+Shift+1 move container to workspace number 1
    bindsym Mod4+Shift+2 move container to workspace number 2
    bindsym Mod4+Shift+3 move container to workspace number 3
    bindsym Mod4+Shift+4 move container to workspace number 4
    bindsym Mod4+Shift+5 move container to workspace number 5
    bindsym Mod4+Shift+6 move container to workspace number 6
    bindsym Mod4+Shift+7 move container to workspace number 7
    bindsym Mod4+Shift+8 move container to workspace number 8
    bindsym Mod4+Shift+9 move container to workspace number 9

    bindsym Mod4+Return       exec ${pkgs.foot}/bin/foot
    bindsym Mod4+Space        exec ${pkgs.fuzzel}/bin/fuzzel
    bindsym Mod4+b            exec ${pkgs.firefox}/bin/firefox
    bindsym Mod4+Shift+b      exec ${pkgs.qutebrowser}/bin/qutebrowser
    bindsym Mod4+q kill

    bindsym Mod4+Shift+s exec '${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Pictures/$(date +"%s_grim.png")'
    bindsym Mod4+Alt+s exec '${pkgs.hyprpicker}/bin/hyprpicker'

    bindsym XF86AudioRaiseVolume exec 'util.lua volume up'
    bindsym XF86AudioLowerVolume exec 'util.lua volume down'

    bindsym XF86MonBrightnessUp exec 'util.lua brightness up'
    bindsym XF86MonBrightnessDown exec 'util.lua brightness down'

    bindsym Home   exec 'util.lua music prev'
    bindsym End    exec 'util.lua music toggle'
    bindsym Insert exec 'util.lua music next'

    default_border pixel 2
    default_floating_border pixel 2
    smart_borders on
    smart_gaps on

    floating_modifier Mod4 normal
  '';
in
  lib.mkIf cfg.enable {
    files = {
      ".config/sway/config".text = settings;
      ".config/sway/catppuccin-mocha".text = colors;
    };

    packages = with pkgs; [
      sway
      wl-clipboard
    ];
  }
