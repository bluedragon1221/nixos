{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    collinux.terminal.packages.tmux = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Whether to enable the tmux terminal multiplexer";
        default = config.collinux.terminal.terminalEmulators.foot.useTmux;
      };
    };
  };

  config = let
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
    };
}
