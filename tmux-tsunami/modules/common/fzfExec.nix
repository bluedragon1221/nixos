{
  tsunamiLib,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (tsunamiLib) scriptPath;
  cfg = config.tsunami.fzfExec;
in {
  options = {
    tsunami.fzfExec = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    tsunami.scripts = {
      # this is buggy af; it only works half the time.
      # But it's the only way I know of to get docs on a specific tmux command
      "tmux-doc" = ''
        usage=$(tmux list-commands -F "#{command_list_name} #{command_list_usage}" "$1")

        man tmux | ${pkgs.gawk}/bin/awk -v usage="$usage" '
          index($0, usage) > 0 { found=1 }
          found {
            print
            if ($0 == "") exit
          }
        '
      '';

      "fzf-exec" = ''
        all_cmds() {
          tmux list-commands -F $'#{command_list_name}#{?command_list_alias,\n#{command_list_alias},}'
        }

        selected_cmd=$(all_cmds | ${pkgs.fzf}/bin/fzf --bind 'enter:accept-or-print-query,tab:replace-query,alt-backspace:clear-query' --prompt : --preview "~/.config/tmux/scripts/tmux-doc.sh $(printf '{}' | cut -d' ' -f1)")
        test -z "$selected_cmd" && exit

        tmux $(echo "$selected_cmd" | sed "s@~@$HOME@g")
      '';
    };

    tsunami.keys.global = [
      {
        key = "M-x";
        exec = "run-shell '${scriptPath "minibuffer"} -h 10 ${scriptPath "fzf-exec"}'";
      }
    ];
  };
}
