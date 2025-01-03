{
  cfgWrapper,
  pkgs,
}: let
  tmux-split = pkgs.writeTextFile {
    name = "tmux-split";
    executable = true;
    text = ''
      #!${pkgs.python3}/bin/python3
      import subprocess

      def tmux_command(*args):
        return subprocess.run(["${pkgs.tmux}/bin/tmux", *args], capture_output=True, text=True)

      width_out = tmux_command("display-message", "-p", "#{pane_width}")
      height_out = tmux_command("display-message", "-p", "#{pane_height}")

      w = int(width_out.stdout)
      h = int(height_out.stdout)

      flag = "-h" if (w / h) > 3.14 else "-v"
      tmux_command("split-window", flag)
    '';
  };

  tmux-bar = let
    arrow = "";
    text = "#c6d0f5";
    blue = "#8aadf4";
    green = "#a6d189";
    bg_dark = "#1D1F32";
    bg_lighter = "#343950";
  in ''
    # Status options
    set -gq status on

    # Basic status bar colors
    set -gq status-bg "${bg_dark}"
    set -gq status-attr none

    # session
    set -gq status-left-length 150
    set -gq status-left "#[fg=${green},bg=${bg_lighter}]   #S #[fg=${bg_lighter},bg=${bg_dark}]${arrow}"

    # Window status format
    set -gq window-status-format         "#[fg=${bg_dark},bg=${bg_lighter}]${arrow}#[fg=${text},bg=${bg_lighter}] #I:#W #[fg=${bg_lighter},bg=${bg_dark}]${arrow}"
    set -gq window-status-current-format "#[fg=${bg_dark},bg=${blue}]${arrow}#[fg=${bg_dark},bg=${blue},bold] #I:#W #[fg=${blue},bg=${bg_dark},nobold]${arrow}"
    set -gq window-status-style          "fg=${blue},bg=${bg_dark},none"
    set -gq window-status-separator ""

    set -gq status-right " "
  '';

  tmux-conf = pkgs.writeText "tmux.conf" ''
    set -g mouse on
    set -g destroy-unattached on

    bind-key -n C-Enter run-shell "${tmux-split}"
    bind-key -n C-w     kill-pane

    bind-key -n C-t     new-window
    bind-key -n C-Tab   next-window
    bind-key -n C-S-Tab previous-window

    ${tmux-bar}

    if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
    set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
    set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
  '';
in
  cfgWrapper {
    pkg = pkgs.tmux;
    binName = "tmux";
    extraFlags = ["-f ${tmux-conf}"];
  }
