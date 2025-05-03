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

      dconf = {
        enable = true;
        settings = {
          "com/raggesilver/BlackBox" = {
            context-aware-header-bar = true;
            fill-tabs = true;
            notify-process-completion = true;
            opacity = 100;
            pixel-scrolling = true;
            pretty = true;
            show-scrollbars = false;
            terminal-padding = "(10, 10, 10, 10)";

            floating-controlls = false;
            show-headerbar = true;
          };
        };
      };
    };
}
