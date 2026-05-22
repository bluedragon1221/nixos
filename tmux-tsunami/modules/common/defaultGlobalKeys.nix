{
  pkgs,
  tsunamiLib,
  ...
}: let
  inherit (tsunamiLib) scriptPath;
in {
  tsunami.scripts."split" = ''
    width=$(tmux display -p "#{pane_width}")
    height=$(tmux display -p "#{pane_height}")

    if (( $(echo "$width / $height > 2.5" | ${pkgs.bc}/bin/bc -l) )); then
      tmux split-window -h "$@"
    else
      tmux split-window -v "$@"
    fi
  '';

  tsunami.scripts."clean-sessions" = ''
    current="$(tmux display -p '#{session_name}')"

    tmux list-sessions -F '#{session_name}' | while read -r line; do
      if [[ "$line" != "$current" && "$line" =~ ^[[:digit:]]+$ ]]; then
        tmux kill-session -t "$line"
      fi
    done
  '';

  tsunami.keys.global = [
    {
      key = "C-w";
      exec = "kill-pane";
    }
    {
      key = "M-z";
      exec = "resize-pane -Z";
    }
    {
      key = "C-Enter";
      exec = ''run-shell "${scriptPath "split"} -c '#{?@default-path,#{@default-path},#{pane_current_path}}'"'';
    }
    {
      key = "C-t";
      exec = "new-window -c '#{?@default-path,#{@default-path},#{pane_current_path}}'";
    }
    {
      key = "C-Tab";
      exec = "next-window";
    }
    {
      key = "C-S-Tab";
      exec = "previous-window";
    }
  ];

  tsunami.confs."windows" = ''
    unbind -n MouseDown3Pane
    set -g allow-rename on
    set -g automatic-rename off
    set -g renumber-windows on
    set -g base-index 1

    set-hook -ag client-detached 'run-shell ${scriptPath "clean-sessions"}'
    set-hook -ag client-session-changed 'run-shell ${scriptPath "clean-sessions"}'
  '';
}
