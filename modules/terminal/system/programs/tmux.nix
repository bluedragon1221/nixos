{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;

  scripts.bat = pkgs.writeShellScriptBin "battery.sh" ''
    energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
    energy_full=$(cat /sys/class/power_supply/BAT0/energy_full)
    percentage=$((energy_now * 100 / energy_full))
    printf "%.0f%%" "$percentage"
  '';

  scripts.primeProjects = pkgs.writeShellScriptBin "projects.sh" ''
    FZF_DEFAULT_OPTS="--color bg:#1E1E2E,bg+:#313244,border:#313244,fg:#CDD6F4,fg+:#CDD6F4,header:#F38BA8,hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,label:#CDD6F4,marker:#B4BEFE,pointer:#F5E0DC,prompt:#CBA6F7,selected-bg:#45475A,spinner:#F5E0DC"

    projects="
      $(find $HOME/projects -maxdepth 1 -mindepth 1 -type d)
      $HOME/Documents/brain2.0
      $HOME/Music
      $HOME/nixos
    "
    if [ $# -eq 1 ]; then
      selected="$1"
    else
      selected="$(echo "$projects" | fzf --tmux --style=minimal --info=hidden $FZF_DEFAULT_OPTS)"
    fi

    [ -z "$selected" ] && exit

    session_name="$(basename "$selected" | tr '.' '_')"

    if tmux list-sessions | grep -q "^$session_name:"; then
      # session already exists, switch to it
      tmux switch -t "$session_name"
    else
      # session doesn't exist, create it and switch to it
      tmux new-session -ds "$session_name" -c "$selected"
      tmux switch -t "$session_name"
    fi
  '';

  scripts.cleanSessions = pkgs.writeShellScriptBin "clean-sessions.sh" ''
    current="$(tmux display-message -p '#S')"

    tmux list-sessions -F '#S' | while read -r line; do
      if [[ "$line" != "$current" && "$line" =~ ^[[:digit:]]+$ ]]; then
        tmux kill-session -t "$line"
      fi
    done
  '';

  scripts.bar = pkgs.writeShellScriptBin "bar.sh" ''
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
    tset status-right "#(${scripts.bat}/bin/battery.sh)"

    ## pane borders
    tset pane-border-style fg=$bg_dark,bg=$bg_dark
    tset pane-active-border-style fg=$bg_dark,bg=$bg_dark

    ## pane backgrounds
    # Set the foreground/background color for the active window
    tset window-active-style bg=$bg_light

    # Set the foreground/background color for all other windows
    tset window-style bg=$bg_dark
  '';

  plugins.tmux-resurrect = builtins.fetchGit {
    url = "https://github.com/tmux-plugins/tmux-resurrect";
    rev = "cff343cf9e81983d3da0c8562b01616f12e8d548";
  };

  tmux-conf = pkgs.writeText "tmux.conf" ''
    # Resurrect
    run-shell ${plugins.tmux-resurrect}/resurrect.tmux
    set -g @resurrect-dir "$HOME/.local/share/tmux-resurrect"
    set -g @resurrect-processes 'hx cmus cava nix-shell'

    set -g mouse on

    # bell
    set -g visual-activity off
    set -g visual-bell off
    set -g visual-silence off
    setw -g monitor-activity off
    set -g bell-action none

    # Panes
    bind-key -n C-w kill-pane

    bind -n C-Enter if -F '#{e|>:#{e|/:#{pane_width},#{pane_height}},2.5}' {
      split-window -h -c '#{pane_current_path}'
    } {
      split-window -v -c '#{pane_current_path}'
    }

    unbind -n MouseDown3Pane ## disable right click menu
    bind-key -n M-z resize-pane -Z ## Pane zoom

    # Windows
    bind-key -n C-t     new-window -c '#{pane_current_path}'
    bind-key -n C-Tab   next-window
    bind-key -n C-S-Tab previous-window # doesn't work in foot :(

    set -g renumber-windows on
    set -g allow-rename off

    # Statusbar
    set-hook -g client-attached 'if -F "#{==:#{session_windows},1}" { set status off } { set status on }'
    set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" { set status off } { set status on }'
    set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" { set status off } { set status on }'

    run-shell "${scripts.bar}/bin/bar.sh"

    # Sessions
    # set-hook -ag client-detached 'run-shell ${scripts.cleanSessions}/bin/clean-sessions.sh'
    # set-hook -ag client-session-changed 'run-shell ${scripts.cleanSessions}/bin/clean-sessions.sh'

    bind-key -n C-f run-shell "${scripts.primeProjects}/bin/projects.sh"
    bind-key -n M-1 run-shell "${scripts.primeProjects}/bin/projects.sh ~/Music"
    bind-key -n M-2 run-shell "${scripts.primeProjects}/bin/projects.sh ~/Documents/brain2.0"
    bind-key -n M-3 run-shell "${scripts.primeProjects}/bin/projects.sh ~/nixos"

    bind-key -n C-g display-popup -E -w 80% -h 80% -x C -y C -d "#{pane_current_path}" "${pkgs.lazygit}/bin/lazygit"
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/tmux/tmux.conf".source = tmux-conf;
      };
      packages = [pkgs.tmux];
    };
  }
