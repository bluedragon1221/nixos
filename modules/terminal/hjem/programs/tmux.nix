{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.tmux;
in {
  imports = [
    inputs.tmux-tsunami.hjemModules.tsunami
  ];

  config = lib.mkIf cfg.enable {
    tsunami = {
      enable = true;

      theme = {
        bg = config.collinux.palette.base01;
        bg_dark = config.collinux.palette.base00;
      };

      keys.leader = [
        {
          name = "Lazygit";
          key = "C-g";
          exec = "display-popup -E -w 80% -h 80% -x C -y C -d '#{?@default-path,#{@default-path},#{pane_current_path}}' ${lib.getExe pkgs.lazygit}";
        }
      ];
      confs."main" = ''
        set -g mouse on
        set-window-option -g mode-keys vi
      '';
    };
  };
}
