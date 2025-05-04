{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.starship;
in
  lib.mkIf (cfg.theme == "minimal") {
    programs.starship.settings = {
      format = ''$directory$git_branch$git_status $character'';

      add_newline = false;
      scan_timeout = 10;

      character = {
        success_symbol = "[λ](green bold)";
        error_symbol = "[Σ](red bold)";
      };

      git_branch.format = "[@$branch](underline)";

      git_status = {
        format = "$modified$staged$ahead$behind";
        modified = "[!](red bold)";
        staged = "[+](green bold)";
        ahead = "[](green)";
        behind = "[](red)";
      };

      directory = {
        format = "$path";
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  }
