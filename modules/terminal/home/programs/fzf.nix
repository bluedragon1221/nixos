{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.fzf;
in
  lib.mkIf cfg.enable {
    catppuccin.fzf.enable = config.collinux.terminal.theme == "catppuccin";
    programs.fzf.enable = true;
  }
