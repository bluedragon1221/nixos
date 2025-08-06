{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;

  scriptsDir = "~/.config/tmux/scripts";

  # -- SESSIONIZER --
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

  scripts.sessionsMenu = ''
    get_nth_session() {
      tmux list-sessions -F "#{session_name}" | sed -n "$1 p"
    }

    switch_nth_session() {
      printf "switch -t $(get_nth_session "$1")"
    }

    tmux display-menu -T "#[align=centre]Projects" -x "#{window_width}" -y S \
      "Switch Project" p "run-shell '${scriptsDir}/minibuffer.sh -d $HOME ${scriptsDir}/launch-sessionizer.sh'" \
      "$(get_nth_session 1)" 1 "$(switch_nth_session 1)" \
      "$(get_nth_session 2)" 2 "$(switch_nth_session 2)" \
      "$(get_nth_session 3)" 3 "$(switch_nth_session 3)" \
      "$(get_nth_session 4)" 4 "$(switch_nth_session 4)"
  '';

  scripts.cleanSessions = ''
    current="$(tmux display -p '#{session_name}')"

    tmux list-sessions -F '#{session_name}' | while read -r line; do
      if [[ "$line" != "$current" && "$line" =~ ^[[:digit:]]+$ ]]; then
        tmux kill-session -t "$line"
      fi
    done
  '';

  scripts.launchSessionizer = ''broot --only-folders --conf ~/.config/tmux/broot/sessionizer.toml'';

  # -- FIND FILE --
  broot_file_config = {
    imports = ["~/.config/broot/conf.toml"];
    quit_on_last_cancel = true;
    verbs = [
      {
        invocation = "tmux-split";
        external = ["bash" "-c" ''${scriptsDir}/split.sh -c "#{?@default-path,#{@default-path},#{pane_current_path}}" "hx '{file}'"''];
        key = "ctrl-s";
        apply_to = "file";
        leave_broot = true;
      }
      {
        invocation = "tmux-window";
        external = ["tmux" "new-window" "-c" "#{?@default-path,#{@default-path},#{pane_current_path}}" "hx '{file}'"];
        key = "ctrl-w";
        apply_to = "file";
        leave_broot = true;
      }
      {
        key = "enter";
        cmd = ":tmux-window";
      }
    ];
  };

  scripts.launchFindFile = ''broot --conf ~/.config/tmux/broot/file.toml'';

  # -- BAR --
  scripts.battery = ''
    energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
    energy_full=$(cat /sys/class/power_supply/BAT0/energy_full)
    percentage=$((energy_now * 100 / energy_full))
    printf "%.0f%%" "$percentage"
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

  # pull up the docs for a specific tmux command
  scripts.tmuxDoc = ''
    usage=$(tmux list-commands -F "#{command_list_name} #{command_list_usage}" "$1")

    man tmux  | awk -v usage="$usage" '
      index($0, usage) > 0 { found=1 }
      found {
        print
        if ($0 == "") exit
      }
    '
  '';

  # replaces `C-b :` with a fancy fzf popup menu with completion and history
  scripts.fzfExec = ''
    all_cmds() {
      tmux list-commands -F $'#{command_list_name}#{?command_list_alias,\n#{command_list_alias},}'
    }

    selected_cmd=$(all_cmds | fzf --bind 'enter:accept-or-print-query,tab:replace-query,alt-backspace:clear-query' --prompt : --preview "~/.config/tmux/scripts/tmux-doc.sh $(printf '{}' | cut -d' ' -f1)")
    test -z "$selected_cmd" && exit

    tmux $(echo "$selected_cmd" | sed "s@~@$HOME@g")
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

    # Emacs-like keybindings
    bind-key -n C-x display-menu -T "#[align=centre]Prefix" -x "#{window_width}" -y S \
      "+Projects" C-p "run-shell ${scriptsDir}/sessions-menu.sh" \
      "Find File" C-f "run-shell \"${scriptsDir}/minibuffer.sh -d '#{?@default-path,#{@default-path},#{pane_current_path}}' '${scriptsDir}/launch-find-file.sh'\"" \
      "Lazygit" C-g "display-popup -E -w 80% -h 80% -x C -y C -d '#{?@default-path,#{@default-path},#{pane_current_path}}' lazygit" \
      "Todo" C-o "display-popup -E -w 70% -h 70% -x C -y C 'hx ~/Documents/todo.txt'" \
      "Reload" C-r "source-file ~/.config/tmux/tmux.conf"

    # Fuzzy command prompt
    bind-key -n M-x run-shell "${scriptsDir}/minibuffer.sh -h 10 '${scriptsDir}/fzf-exec.sh'"

    # Statusbar
    run-shell "${scriptsDir}/bar.sh"

    set-hook -ag client-detached 'run-shell ${scriptsDir}/clean-sessions.sh'
    set-hook -ag client-session-changed 'run-shell ${scriptsDir}/clean-sessions.sh'

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
        ".config/tmux/scripts/minibuffer.sh" = e scripts.minibuffer;

        # sessionizer
        ".config/tmux/scripts/sessionizer.sh" = e scripts.sessionizer;
        ".config/tmux/broot/sessionizer.toml" = {
          generator = (pkgs.formats.toml {}).generate "sessionizer.toml";
          value = broot_sessionizer_config;
        };
        ".config/tmux/scripts/launch-sessionizer.sh" = e scripts.launchSessionizer;
        ".config/tmux/scripts/clean-sessions.sh" = e scripts.cleanSessions;
        ".config/tmux/scripts/sessions-menu.sh" = e scripts.sessionsMenu;

        # find-file
        ".config/tmux/scripts/launch-find-file.sh" = e scripts.launchFindFile;
        ".config/tmux/broot/file.toml" = {
          generator = (pkgs.formats.toml {}).generate "file.toml";
          value = broot_file_config;
        };

        # fzf-exec
        ".config/tmux/scripts/tmux-doc.sh" = e scripts.tmuxDoc;
        ".config/tmux/scripts/fzf-exec.sh" = e scripts.fzfExec;

        # Bar
        ".config/tmux/scripts/battery.sh" = e scripts.battery;
        ".config/tmux/scripts/bar.sh" = e scripts.bar;

        ".config/tmux/scripts/split.sh" = e scripts.paneSplit;

        ".config/tmux/tmux.conf".text = tmux-conf;
      };

      packages = [pkgs.tmux];
    };
  }
