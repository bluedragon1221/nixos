{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.eza;
in
  lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      extraOptions = ["-A" "-w" "80" "--group-directories-first" "-I .git*"];
    };

    home.shellAliases = {
      "ls" = "eza";
      "ll" = "ls -l";
      "tree" = "ls -T";
      "lsg" = "ls -l --git --no-permissions --no-user --no-time --icons";
    };
  }
