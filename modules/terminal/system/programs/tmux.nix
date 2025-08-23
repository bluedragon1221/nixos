{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;

  scriptsDir = "~/.config/tmux/scripts";

  scripts.minibuffer = ''
    window_height="$(tmux display -p '#{window_height}')"
    tmux display-popup -EB \
      -w 100% -h 16 \
      -x 0 -y "$(($window_height + 1))" \
      "$@"
  '';

  scripts.menu = ''
    tmux display-menu \
      -x "#{window_width}" -y S \
      -b none \
      -s "bg=#313244,fg=#9399b2" \
      -S "bg=#313244" \
      -H "bg=#45475a fg=#b4befe" \
      "$@"
  '';

  scripts.paneSplit = ''
    width=$(tmux display -p "#{pane_width}")
    height=$(tmux display -p "#{pane_height}")

    if (( $(echo "$width / $height > 2.5" | bc -l) )); then
      tmux split-window -h "$@"
    else
      tmux split-window -v "$@"
    fi
  '';

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
    menu_items=(
      "Switch Project" p "run-shell '${scriptsDir}/minibuffer.sh -d $HOME ${scriptsDir}/launch-sessionizer.sh'"
    )

    # Get all tmux session names
    mapfile -t sessions < <(tmux list-sessions -F "#{session_name}")

    # Only include up to 9 sessions
    for i in "''\${!sessions[@]}"; do
      (( i >= 9 )) && break  # Stop after 9 sessions

      session="''\${sessions[$i]}"
      key=$((i + 1))  # 1-based key

      menu_items+=("$session" "$key" "switch-client -t $session")
    done

    # Display the menu
    ${scriptsDir}/menu.sh -T "#[align=centre]Projects" "''\${menu_items[@]}"
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
    tmux set -g status on

    tmux set -g status-position bottom
    tmux set -g status-justify absolute-centre
    tmux set -g status-bg bg

    tmux set -g status-left-style fg=green,bold
    tmux set -g status-left " #{client_session}"

    tmux set -g window-status-style fg=color243
    tmux set -g window-status-format " #I "
    tmux set -g window-status-current-style fg=color12,bold
    tmux set -g window-status-current-format " #I "
    tmux set -g window-status-separator ""

    tmux set -g status-right "#[fg=color243]%l:%M  #[fg=red]#(${scriptsDir}/battery.sh) "

    bg_dark="#181825"

    ## pane borders
    tmux set -g pane-border-style fg=$bg_dark,bg=$bg_dark
    tmux set -g pane-active-border-style fg=$bg_dark,bg=$bg_dark

    ## pane backgrounds
    # Set the foreground/background color for the active window
    tmux set -g window-active-style bg=bg

    # Set the foreground/background color for all other windows
    tmux set -g window-style bg=$bg_dark
  '';

  # -- FZF EXEC --
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

  scripts.fzfExec = ''
    all_cmds() {
      tmux list-commands -F $'#{command_list_name}#{?command_list_alias,\n#{command_list_alias},}'
    }

    selected_cmd=$(all_cmds | fzf --bind 'enter:accept-or-print-query,tab:replace-query,alt-backspace:clear-query' --prompt : --preview "~/.config/tmux/scripts/tmux-doc.sh $(printf '{}' | cut -d' ' -f1)")
    test -z "$selected_cmd" && exit

    tmux $(echo "$selected_cmd" | sed "s@~@$HOME@g")
  '';

  # -- BUFFER SEARCH --
  scripts.searchBuffer = ''
    trap 'rm -f -- "''\${scrollback:-}"' EXIT
    scrollback="$(mktemp)"

    tmux capture-pane -e -p -S - > "$scrollback"
    cat "$scrollback" | fzf --ansi

    exit 0
  '';

  # -- PANE SEARCH --
  scripts.paneSearch = ''
    LIST_DATA="#{window_name} #{pane_title} #{pane_current_path} #{pane_current_command}"
    FZF_COMMAND="fzf-tmux -p --delimiter=: --with-nth 4 --color=hl:2"

    # do not change
    TARGET_SPEC="#{session_name}:#{window_id}:#{pane_id}:"

    # select pane
    LINE=$(tmux list-panes -a -F "$TARGET_SPEC $LIST_DATA" | $FZF_COMMAND) || exit 0
    # split the result
    args=(''\${LINE//:/ })
    # activate session/window/pane
    tmux select-pane -t ''\${args[2]} && tmux select-window -t ''\${args[1]} && tmux switch-client -t ''\${args[0]}
  '';

  # -- LEADER MENU --
  scripts.leaderMenu = ''
    ${scriptsDir}/menu.sh -T "#[align=centre]Prefix" \
      "+Projects" C-p "run-shell ${scriptsDir}/sessions-menu.sh" \
      "Find File" C-f "run-shell \"${scriptsDir}/minibuffer.sh -d '#{?@default-path,#{@default-path},#{pane_current_path}}' '${scriptsDir}/launch-find-file.sh'\"" \
      "Find Window" C-w "run-shell \"${scriptsDir}/minibuffer.sh '${scriptsDir}/pane-search.sh'\"" \
      "Lazygit" C-g "display-popup -E -w 80% -h 80% -x C -y C -d '#{?@default-path,#{@default-path},#{pane_current_path}}' lazygit" \
      "Search Buffer" / "run-shell \"${scriptsDir}/minibuffer.sh '${scriptsDir}/search-buffer.sh'\"" \
      "Todo" C-o "display-popup -E -w 70% -h 70% -x C -y C 'hx ~/Documents/todo.txt'" \
      "Reload" C-r "source-file ~/.config/tmux/tmux.conf"
  '';

  tmux-conf = ''
    set -g mouse on
    set -g default-terminal "tmux"

    # Panes
    bind-key -n C-w kill-pane

    bind -n C-Enter run-shell "${scriptsDir}/split.sh -c '#{?@default-path,#{@default-path},#{pane_current_path}}'"

    unbind -n MouseDown3Pane ## disable right click menu
    bind-key -n M-z resize-pane -Z ## Pane zoom
    set -g allow-rename on
    set -g automatic-rename off

    # Windows
    bind-key -n C-t     new-window -c '#{?@default-path,#{@default-path},#{pane_current_path}}'
    bind-key -n C-Tab   next-window
    bind-key -n C-S-Tab previous-window # doesn't work in foot :(
    unbind n
    unbind p

    set -g renumber-windows on
    set -g base-index 1

    bind-key -n C-x run-shell "${scriptsDir}/leader-menu.sh"
    bind-key -n M-x run-shell "${scriptsDir}/minibuffer.sh -h 10 '${scriptsDir}/fzf-exec.sh'"

    set-hook -ag client-detached 'run-shell ${scriptsDir}/clean-sessions.sh'
    set-hook -ag client-session-changed 'run-shell ${scriptsDir}/clean-sessions.sh'

    # Statusbar
    run-shell "${scriptsDir}/bar.sh"

    # Scrollback
    set-window-option -g mode-keys vi
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
        # helpers
        ".config/tmux/scripts/minibuffer.sh" = e scripts.minibuffer;
        ".config/tmux/scripts/menu.sh" = e scripts.menu;
        ".config/tmux/scripts/split.sh" = e scripts.paneSplit;

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

        # search buffer
        ".config/tmux/scripts/search-buffer.sh" = e scripts.searchBuffer;

        # pane search
        ".config/tmux/scripts/pane-search.sh" = e scripts.paneSearch;

        # fzf-exec
        ".config/tmux/scripts/tmux-doc.sh" = e scripts.tmuxDoc;
        ".config/tmux/scripts/fzf-exec.sh" = e scripts.fzfExec;

        # leader menu
        ".config/tmux/scripts/leader-menu.sh" = e scripts.leaderMenu;

        # Bar
        ".config/tmux/scripts/battery.sh" = e scripts.battery;
        ".config/tmux/scripts/bar.sh" = e scripts.bar;

        ".config/tmux/tmux.conf".text = tmux-conf;
      };

      packages = [pkgs.tmux];
    };
  }
