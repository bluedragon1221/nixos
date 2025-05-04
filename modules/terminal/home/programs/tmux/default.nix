{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.packages.tmux;
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
          if (config.collinux.terminal.theme == "catppuccin")
          then "run-shell ${./bar.sh}"
          else ""
        }
      '';
    };
  }
