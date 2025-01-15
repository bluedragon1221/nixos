{
  cfgWrapper,
  pkgs,
}: let
  settings = (pkgs.formats.toml {}).generate "starship.toml" {
    add_newline = false;
    format = ''$nix_shell$directory$git_branch$git_status $character'';

    scan_timeout = 10;

    character = {
      success_symbol = "[λ](green bold)";
      error_symbol = "[λ](red bold)";
    };

    git_branch.format = "[@$branch](underline)";

    git_status = {
      format = "$modified$staged$ahead$behind";
      modified = "[!](red bold)";
      staged = "[+](green bold)";
      ahead = "[⇡](green)";
      behind = "[⇣](red)";
    };

    directory = {
      format = "$path";
      truncation_length = 3;
      truncate_to_repo = true;
    };

    nix_shell = {
      format = "[$name](blue bold) ";
    };
  };
in
  cfgWrapper {
    pkg = pkgs.starship;
    binName = "starship";
    extraEnv.STARSHIP_CONFIG = settings;
  }
