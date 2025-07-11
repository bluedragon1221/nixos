{
  pkgs,
  lib,
  config,
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

  scripts.sessionizer = ''
    projects="$(find $HOME/projects -maxdepth 1 -mindepth 1 -type d)
    $HOME/Pictures/experiments
    $HOME/brain
    $HOME/nixos"

    if [ $# -eq 1 ]; then
      selected="$1"
    else
      tmpfile="$(mktemp)"
      ${scriptsDir}/minibuffer.sh "echo '$projects' | fzf --style=minimal --info=hidden --color bg:#181825 > '$tmpfile'"
      selected="$(cat "$tmpfile")"
      rm "$tmpfile"
    fi

    [ -z "$selected" ] && exit

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

    tset status-left-style fg=$green
    tset status-left "   #{client_session} "

    tset window-status-style fg=$text_dark
    tset window-status-format "#I:#W"
    tset window-status-current-style fg=$blue,bold
    tset window-status-current-format "#I:#W"
    tset window-status-separator " "

    tset status-right-style fg=$red
    tset status-right "#(${scriptsDir}/battery.sh)"

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

    # Windows
    bind-key -n C-t     new-window -c '#{?@default-path,#{@default-path},#{pane_current_path}}'
    bind-key -n C-Tab   next-window
    bind-key -n C-S-Tab previous-window # doesn't work in foot :(

    set -g renumber-windows on
    set -g allow-rename on

    # Statusbar
    set-hook -g client-attached 'if -F "#{==:#{session_windows},1}" { set status off } { set status on }'
    set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" { set status off } { set status on }'
    set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" { set status off } { set status on }'

    ${
      if (cfg.theme == "catppuccin")
      then "run-shell '${scriptsDir}/bar.sh'"
      else ""
    }

    # Sessions
    set-hook -ag client-detached 'run-shell ${scriptsDir}/clean-sessions.sh'
    set-hook -ag client-session-changed 'run-shell ${scriptsDir}/clean-sessions.sh'

    bind-key -n C-g display-popup -E -w 80% -h 80% -x C -y C -d "#{?@default-path,#{@default-path},#{pane_current_path}}" "${pkgs.lazygit}/bin/lazygit"
    bind-key -n C-o display-popup -E -w 70% -h 70% -x C -y C "hx ~/Documents/todo.txt"

    bind-key -n C-f run-shell "${scriptsDir}/sessionizer.sh"

    # 1. C-h to open broot in bottom (like emacs minibuffer)
    # 2. search for file
    # 'enter' to open it in current pane (kills current running process in that pane)
    # or 'alt-enter' to open it in new pane
    # quiting editor will send back to fish (not close the pane)
    bind-key -n C-h run-shell "${scriptsDir}/minibuffer.sh 'broot --conf ~/.config/tmux/broot_popup.toml'"
  '';

  scripts.minibuffer = ''
    window_height="$(tmux display -p '#{window_height}')"
    tmux display-popup -EB \
      -w 100% -h 16 \
      -x 0 -y "$(($window_height + 1))" \
      -d '#{pane_current_path}' \
      "$@"
  '';

  # binding for broot-minibuffer's alt-enter
  scripts.smartOpen = ''
    if [[ "$1" = "-t" ]]; then
      # `alt-enter` mode
      ${scriptsDir}/split.sh -c "#{?@default-path,#{@default-path},#{pane_current_path}}" "hx \"$2\"; exec fish"
    else
      # `enter` mode
      file="$1"

      [ -z "$file" ] && exit 1

      # 1. If there is already a pane that looks like "hx {file}", switch to that pane
      while IFS='|' read -r window pane title; do
        if [[ "$title" = "hx $file" ]]; then
          tmux select-window -t "$window"
          tmux select-pane -t "$pane"
          exit 0
        fi
      done < <(tmux list-panes -sF "#{window_id}|#{pane_id}|#{pane_title}")

    	# 2. If the current pane is a shell (fish or bash), send-keys "hx {file}"
    	pane_title="$(tmux display -p '#{pane_title}')"
    	if [[ "$pane_title" =~ ^(fish|bash).*$ ]]; then
        tmux send-keys "hx \"$file\"" C-m
        exit 0

    	# 3. If the current pane is helix, send-keys ":o {file}"
      elif [[ "$pane_title" =~ ^hx.*$ ]]; then
        tmux send-keys ":o \"$file\"" C-m
        exit 0
      fi

    	# 4. Otherwise, open the file in a new pane
    	${scriptsDir}/smart-open.sh -t "$file"
    fi
  '';

  broot_popup_config = {
    imports = ["~/.config/broot/conf.toml"]; # for the colortheme
    quit_on_last_cancel = true;
    verbs = [
      {
        invocation = "replace_tmux";
        key = "enter";
        external = ''bash -c -- "${scriptsDir}/smart-open.sh '{file}'"'';
      }
      {
        invocation = "open_tmux";
        key = "alt-enter";
        external = ''bash -c -- "${scriptsDir}/smart-open.sh -t '{file}'"'';
      }
    ];
  };
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
        ".config/tmux/scripts/smart-open.sh" = e scripts.smartOpen;

        ".config/tmux/broot_popup.toml" = {
          generator = (pkgs.formats.toml {}).generate "broot_popup.toml";
          value = broot_popup_config;
        };

        ".config/tmux/tmux.conf".text = tmux-conf;
      };

      packages = [pkgs.tmux];
    };
  }
