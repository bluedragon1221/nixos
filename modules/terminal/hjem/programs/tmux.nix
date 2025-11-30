{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;
in {
  imports = [
    inputs.tmux-tsunami.hjemModules.tsunami
  ];

  config = lib.mkIf cfg.enable {
    tsunami = {
      enable = true;

      theme =
        if (cfg.theme == "catppuccin")
        then {
          bg = "#1e1e2e";
          bg_dark = "#181825";
        }
        else if (cfg.theme == "adwaita")
        then {
          bg = "#1d1d1d";
          bg_dark = "#171717";
        }
        else {};

      scripts.switch_to_utility =
        # bash
        ''
          # if utility session doesn't exist, create it
          if ! tmux has-session -t "utility"; then
            tmux new-session -ds "utility" -c "$HOME"
          fi

          if [ -z "$TMUX" ]; then
            # we're not in tmux
            tmux attach-session -t "utility"
          else
            tmux switch -t "utility"
          fi

          # if cmus window doesn't exist, create it
          if ! tmux list-windows -t "utility" -F "#{window_name}" | grep -qx "utility_cmus"; then
            tmux new-window -t "utility" -n "utility_cmus" "cmus"
          fi

          # if bluetuith window doesn't exist, create it
          if ! tmux list-windows -t "utility" -F "#{window_name}" | grep -qx "utility_bluetuith"; then
            tmux new-window -t "utility" -n "utility_bluetuith" "bluetuith"
          fi
        '';

      keys.leader = [
        {
          name = "Lazygit";
          key = "C-g";
          exec = "display-popup -E -w 80% -h 80% -x C -y C -d '#{?@default-path,#{@default-path},#{pane_current_path}}' ${lib.getExe pkgs.lazygit}";
        }
        {
          name = "Utility";
          key = "C-u";
          exec = "display-popup -w 80% -h 80% -x C -y C 'TMUX= ~/.config/tmux/scripts/switch_to_utility.sh'";
        }
      ];
      confs."main" = ''
        set -g mouse on
        set-window-option -g mode-keys vi
      '';
    };
  };
}
