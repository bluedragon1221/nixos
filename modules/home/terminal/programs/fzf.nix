{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    collinux.terminal.programs.fzf = {
      enable = lib.mkEnableOption "fzf";
    };
  };

  config = let
    cfg = config.collinux.terminal.programs.fzf;
  in
    lib.mkIf cfg.enable {
      catppuccin.fzf.enable = config.collinux.terminal.theme == "catppuccin";
      programs.fzf.enable = true;
    };
}
