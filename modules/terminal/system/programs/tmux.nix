{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;

  scriptsDir = "~/.config/tmux/scripts";

  scripts.battery = ''
    energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
    energy_full=$(cat /sys/class/power_supply/BAT0/energy_full)
    percentage=$((energy_now * 100 / energy_full))
    printf "%.0f%%" "$percentage"
  '';

  broot_sessionizer_config = {
    imports = ["~/.config/broot/conf.toml"];
    quit_on_last_cancel = true;
    verbs = [
      {
        invocation = "sessionizer";
        external = ''bash -c -- "${scriptsDir}/sessionizer.sh '{file}'"'';
        key = "enter";
        apply_to = "directory";
        leave_broot = true;
      }
    ];
  };

  scripts.sessionizer = ''
    selected="$1"

    session_name="$(basename "$selected" | tr '.' '_')"

    # if the session doesn't exist, create it
    if tmux list-sessions -F '#{session_name}' | grep -vqx "$session_name"; then
      tmux new-session -ds "$session_name" -c "$selected"
      tmux set-option -t "$session_name" @default-path "$selected"
    fi

    # switch to it
    tmux switch -t "$session_name"
  '';

  scripts.cleanSessions = ''
    current="$(tmux display -p '#{session_name}')"

    tmux list-sessions -F '#{session_name}' | while read -r line; do
      if [[ "$line" != "$current" && "$line" =~ ^[[:digit:]]+$ ]]; then
        tmux kill-session -t "$line"
      fi
    done
  '';

  scripts.bar = ''
    text="#c6d0f5"
    text_dark="#7F849C"
    blue="#b3befe"
    green="#a6d189"
    red="#f38ba8"
    bg_dark="#181825"
    bg_light="#1E1E2E"

    tset() {
      tmux set -gq "$@"
    }

    tset status on

    tset status-position bottom
    tset status-justify absolute-centre
    tset status-bg $bg_light

    tset status-left-style fg=$green,bold
    tset status-left " #{client_session}"

    tset window-status-style fg=$text_dark
    tset window-status-format " #I "
    tset window-status-current-style fg=$blue,bold
    tset window-status-current-format " #I "
    tset window-status-separator ""

    tset status-right "#[fg=$text_dark]%l:%M  #[fg=$red]#(${scriptsDir}/battery.sh) "

    ## pane borders
    tset pane-border-style fg=$bg_dark,bg=$bg_dark
    tset pane-active-border-style fg=$bg_dark,bg=$bg_dark

    ## pane backgrounds
    # Set the foreground/background color for the active window
    tset window-active-style bg=$bg_light

    # Set the foreground/background color for all other windows
    tset window-style bg=$bg_dark
  '';

  scripts.paneSplit = ''
    #!/usr/bin/env bash
    width=$(tmux display -p "#{pane_width}")
    height=$(tmux display -p "#{pane_height}")

    if (( $(echo "$width / $height > 2.5" | bc -l) )); then
      tmux split-window -h "$@"
    else
      tmux split-window -v "$@"
    fi
  '';

  plugins.fuzzback = builtins.fetchGit {
    url = "https://github.com/roosta/tmux-fuzzback";
    rev = "0aafeeec4555d7b44a5a2a8252f29c238d954d59";
  };

  tmux-conf = ''
    set -g mouse on

    # bell
    set -g visual-activity off
    set -g visual-bell off
    set -g visual-silence off
    setw -g monitor-activity off
    set -g bell-action none

    # Panes
    bind-key -n C-w kill-pane

    bind -n C-Enter run-shell "${scriptsDir}/split.sh -c '#{?@default-path,#{@default-path},#{pane_current_path}}'"

    unbind -n MouseDown3Pane ## disable right click menu
    bind-key -n M-z resize-pane -Z ## Pane zoom
    set -g allow-rename on

    # Windows
    bind-key -n C-t     new-window -c '#{?@default-path,#{@default-path},#{pane_current_path}}'
    bind-key -n C-Tab   next-window
    bind-key -n C-S-Tab previous-window # doesn't work in foot :(
    set -g renumber-windows on
    set -g base-index 1

    # Sessions
    bind-key -n C-f run-shell "${scriptsDir}/minibuffer.sh -d '$HOME' 'broot --conf ~/.config/tmux/broot_sessionizer.toml'"

    # Statusbar
    run-shell "${scriptsDir}/bar.sh"

    set-hook -ag client-detached 'run-shell ${scriptsDir}/clean-sessions.sh'
    set-hook -ag client-session-changed 'run-shell ${scriptsDir}/clean-sessions.sh'

    bind-key -n C-g display-popup -E -w 80% -h 80% -x C -y C -d "#{?@default-path,#{@default-path},#{pane_current_path}}" "${pkgs.lazygit}/bin/lazygit"
    bind-key o display-popup -E -w 70% -h 70% -x C -y C "hx ~/Documents/todo.txt"

    # Scrollback
    set -g @fuzzback-popup 1
    bind-key -T copy-mode -n / run-shell "${plugins.fuzzback}/scripts/fuzzback.sh"
  '';

  scripts.minibuffer = ''
    window_height="$(tmux display -p '#{window_height}')"
    tmux display-popup -EB \
      -w 100% -h 16 \
      -x 0 -y "$(($window_height + 1))" \
      "$@"
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = let
        e = text: {
          inherit text;
          executable = true;
        };
      in {
        ".config/tmux/scripts/battery.sh" = e scripts.battery;
        ".config/tmux/scripts/sessionizer.sh" = e scripts.sessionizer;
        ".config/tmux/scripts/clean-sessions.sh" = e scripts.cleanSessions;
        ".config/tmux/scripts/bar.sh" = e scripts.bar;
        ".config/tmux/scripts/split.sh" = e scripts.paneSplit;
        ".config/tmux/scripts/minibuffer.sh" = e scripts.minibuffer;

        ".config/tmux/broot/sessionizer.toml" = {
          generator = (pkgs.formats.toml {}).generate "broot_sessionizer.toml";
          value = broot_sessionizer_config;
        };

        ".config/tmux/tmux.conf".text = tmux-conf;
      };

      packages = [pkgs.tmux];
    };
  }
