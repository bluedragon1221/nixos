{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;
in
  lib.mkIf cfg.enable {
    home.shell.enableFishIntegration = true;

    catppuccin.fish.enable = config.collinux.terminal.theme == "catppuccin";
    programs.fish = {
      enable = true;
      generateCompletions = true;
      shellInit = ''
        set fish_greeting
      '';
    };
  }
