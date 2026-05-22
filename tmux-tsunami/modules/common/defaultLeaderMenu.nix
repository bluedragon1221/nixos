{tsunamiLib, ...}: let
  inherit (tsunamiLib) scriptPath;
in {
  tsunami.scripts = {
    "find-pane" = ''
      display_format="#{window_name} #{pane_title} #{pane_current_path} #{pane_current_command}"
      hidden_format="#{session_name}:#{window_id}:#{pane_id}"

      # select pane
      selected=$(tmux list-panes -a -F "$hidden_format:$display_format" | fzf --delimiter=: --with-nth 4 --color=hl:2)
      [ -z "$selected" ] || exit

      # switch to selected
      args=(''\${selected//:/ })
      tmux select-pane -t ''\${args[2]} && tmux select-window -t ''\${args[1]} && tmux switch-client -t ''\${args[0]}
    '';

    "search-pane" = ''
      trap 'rm -f -- "''\${scrollback:-}"' EXIT
      scrollback="$(mktemp)"

      tmux capture-pane -e -p -S - > "$scrollback"
      cat "$scrollback" | fzf --ansi

      exit 0
    '';
  };

  tsunami.keys.leader = [
    {
      name = "Find Pane";
      key = "C-w";
      exec = ''run-shell "${scriptPath "minibuffer"} '${scriptPath "find-pane"}'"'';
    }
    {
      name = "Search Pane";
      key = "C-/";
      exec = ''run-shell "${scriptPath "minibuffer"} '${scriptPath "search-pane"}'"'';
    }
    {
      name = "Detach";
      key = "C-d";
      exec = "detach";
    }
    {
      name = "Reload";
      key = "C-r";
      exec = "source-file ~/.config/tmux/tmux.conf";
    }
  ];
}
