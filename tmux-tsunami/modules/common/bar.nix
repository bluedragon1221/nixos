{
  config,
  lib,
  tsunamiLib,
  ...
}: let
  inherit (tsunamiLib) scriptPath;
in {
  options = let
    hexColor = lib.types.strMatching "^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$";
  in {
    tsunami.theme = {
      bg = lib.mkOption {
        type = hexColor;
        default = "#fff";
      };
      bg_dark = lib.mkOption {
        type = hexColor;
        default = "#000";
      };
    };
  };
  config = {
    tsunami = {
      scripts = {
        "battery" = ''
          energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
          energy_full=$(cat /sys/class/power_supply/BAT0/energy_full)
          percentage=$((energy_now * 100 / energy_full))
          printf "%.0f%%" "$percentage"
        '';

        "bar" = ''
          tmux set -g status on

          tmux set -g status-position bottom
          tmux set -g status-justify absolute-centre
          tmux set -g status-bg "${config.tsunami.theme.bg}"

          tmux set -g status-left-style fg=green,bold
          tmux set -g status-left " #{client_session}"

          tmux set -g window-status-style fg=color243
          tmux set -g window-status-format " #I "
          tmux set -g window-status-current-style fg=color12,bold
          tmux set -g window-status-current-format " #I "
          tmux set -g window-status-separator ""

          tmux set -g status-right "#[fg=color243]%l:%M  #[fg=red]#(${scriptPath "battery"}) "

          ## pane borders
          tmux set -g pane-border-style fg=${config.tsunami.theme.bg_dark},bg=${config.tsunami.theme.bg_dark}
          tmux set -g pane-active-border-style fg=${config.tsunami.theme.bg_dark},bg=${config.tsunami.theme.bg_dark}

          ## pane backgrounds
          # Set the foreground/background color for the active window
          tmux set -g window-active-style bg=${config.tsunami.theme.bg}

          # Set the foreground/background color for all other windows
          tmux set -g window-style bg=${config.tsunami.theme.bg_dark}
        '';
      };

      confs."bar" = ''
        run-shell ${scriptPath "bar"}
      '';
    };
  };
}
