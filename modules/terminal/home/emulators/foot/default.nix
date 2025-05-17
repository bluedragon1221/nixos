{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.terminalEmulators.foot;
in
  lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings.main = {
        font = "${config.collinux.terminal.font.name}:size=12";
        shell = lib.mkIf config.collinux.terminal.terminalEmulators.useTmux "${pkgs.tmux}/bin/tmux";

        extraConfig =
          if cfg.theme == "catppuccin"
          then builtins.readFile ./catppuccin.ini
          else "";
      };
    };
  }
