{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options = {
    collinux.terminal.terminalEmulators.blackbox = {
      enable = mkEnableOption "the Black Box terminal emulator (looks best in gnome)";
    };
  };

  config = let
    cfg = config.collinux.terminal.terminalEmulators.blackbox;
  in
    lib.mkIf cfg.enable {
      home.packages = [pkgs.blackbox-terminal];
    };
}
