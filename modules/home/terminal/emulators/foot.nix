{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    collinux.terminal.terminalEmulators.foot = {
      enable = mkEnableOption "The foot terminal emulator";
      useTmux = mkOption {
        type = types.bool;
        description = "Make new tmux sessions in new foot windows to allow for splitting and tabs";
      };
    };
  };

  config = let
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
    };
}
