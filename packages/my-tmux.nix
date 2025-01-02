{
  cfgWrapper,
  my-fish,
  pkgs,
}: let
  tmux-split = pkgs.writeTextFile {
    name = "tmux-split";
    executable = true;
    text = ''
      #!${pkgs.python3}/bin/python3
      import subprocess
      width_out = subprocess.run(["tmux", "display-message", "-p", "#{pane_width}"], capture_output=True, text=True)
      height_out = subprocess.run(["tmux", "display-message", "-p", "#{pane_height}"], capture_output=True, text=True)

      w = int(width_out.stdout)
      h = int(height_out.stdout)

      flag = "-h" if (w / h) > 2.5 else "-v"
      subprocess.run(["tmux", "split-window", flag])
    '';
  };

  tmux-conf = pkgs.writeText "tmux.conf" ''
    set -g mouse on
    set -g status off
    set-option -g default-shell ${my-fish}/bin/fish

    bind-key -n C-Enter run-shell "${tmux-split}"
  '';
in
  cfgWrapper {
    pkg = pkgs.tmux;
    binName = "tmux";
    extraFlags = ["-f ${tmux-conf}"];
  }
