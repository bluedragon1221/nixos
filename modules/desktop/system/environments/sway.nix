{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.sway;

  colors = pkgs.writeText "catppuccin-mocha" ''
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

  settings = pkgs.writeText "config" ''
    exec ${pkgs.foot}/bin/foot --server
    exec ${pkgs.swaybg}/bin/swaybg -i ${config.collinux.desktop.wallpaper}
    exec ${pkgs.dunst}/bin/dunst

    include catppuccin-mocha

    # target                 title     bg    text   indicator  border
    client.focused           $lavender $base $text  $rosewater $lavender
    client.focused_inactive  $overlay0 $base $text  $rosewater $overlay0
    client.unfocused         $overlay0 $base $text  $rosewater $overlay0
    client.urgent            $peach    $base $peach $overlay0  $peach
    client.placeholder       $overlay0 $base $text  $overlay0  $overlay0
    client.background        $base

    # bar {
    #   colors {
    #     background         $base
    #     statusline         $text
    #     focused_statusline $text
    #     focused_separator  $base

    #     # target           border bg        text
    #     focused_workspace  $base  $mauve    $crust
    #     active_workspace   $base  $surface2 $text
    #     inactive_workspace $base  $base     $text
    #     urgent_workspace   $base  $red      $crust
    #   }
    # }

    bindsym Mod4+1 workspace number 1
    bindsym Mod4+2 workspace number 2
    bindsym Mod4+3 workspace number 3
    bindsym Mod4+4 workspace number 4
    bindsym Mod4+Shift+1 move container to workspace number 1
    bindsym Mod4+Shift+2 move container to workspace number 2
    bindsym Mod4+Shift+3 move container to workspace number 3
    bindsym Mod4+Shift+4 move container to workspace number 4

    bindsym Mod4+Return exec "${pkgs.foot}/bin/footclient"
    bindsym Mod4+Shift+Return exec ${pkgs.foot}/bin/foot
    bindsym Mod4+Space exec ${pkgs.fuzzel}/bin/fuzzel
    bindsym Mod4+b exec ${pkgs.firefox}/bin/firefox
    bindsym Mod4+Shift+b exec ${pkgs.qutebrowser}/bin/qutebrowser
    bindsym Mod4+q kill

    bindsym XF86AudioRaiseVolume exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+; dunstify -t 300 -h string:x-canonical-private-synchronous:audio "Volume: " -h int:value:"$(dec=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume:\ //'); echo "$dec * 100" | bc)"'
    bindsym XF86AudioLowerVolume exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -t 300 -h string:x-canonical-private-synchronous:audio "Volume: " -h int:value:"$(dec=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume:\ //'); echo "$dec * 100" | bc)"'

    default_border pixel 2
    smart_borders on
    smart_gaps on
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/sway/config".source = settings;
        ".config/sway/catppuccin-mocha".source = colors;
      };

      packages = [pkgs.sway pkgs.bc];
    };

    # Greetd
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.sway}/bin/sway";
          user = config.collinux.user.name;
        };
        default_session = initial_session;
      };
    };
  }
