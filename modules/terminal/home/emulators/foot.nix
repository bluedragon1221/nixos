{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.terminalEmulators.foot;
in
  lib.mkIf cfg.enable {
    catppuccin.foot.enable = config.collinux.terminal.theme == "catppuccin";
    programs.foot = {
      enable = true;
      server.enable = true;
      settings.main = {
        font = "IosevkaNerdFont:size=12";
        shell = lib.mkIf cfg.useTmux "${pkgs.tmux}/bin/tmux";
      };
    };
  }
