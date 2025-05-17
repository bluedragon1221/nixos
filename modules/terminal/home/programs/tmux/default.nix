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
      '';
    };

    home.packages = [pkgs.tmux-xpanes];
  }
