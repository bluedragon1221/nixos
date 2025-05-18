{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;
in
  lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      terminal = "tmux-256color";
      escapeTime = 0;
      extraConfig = ''
        source-file ${./tmux.conf}
        ${
          if (cfg.theme == "catppuccin")
          then "\nrun-shell ${./bar.sh}"
          else ""
        }

        ${
          if config.collinux.terminal.programs.lazygit.enable
          then ''
            bind-key -n C-g display-popup -E -w 80% -h 80% -x C -y C -d "#{pane_current_path}" "lazygit"''
          else ""
        }
      '';
    };

    home.packages = [pkgs.tmux-xpanes];
  }
