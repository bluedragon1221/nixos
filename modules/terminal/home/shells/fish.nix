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

      functions = {
        starship_transient_prompt_func = {
          body = "starship module character";
        };
      };

      shellInit = ''
        set fish_greeting
      '';

      shellInitLast = ''
        enable_transience
      '';
    };
  }
