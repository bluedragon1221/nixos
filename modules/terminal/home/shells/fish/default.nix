{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;
in
  lib.mkIf cfg.enable {
    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;
      generateCompletions = true;
      shellInit = ''
        set fish_greeting
      '';
    };
  }
