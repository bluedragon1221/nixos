{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.starship;
  toml' = pkgs.formats.toml {};

  settings = toml'.generate "starship.toml" {
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
      ahead = "[/](green)";
      behind = "[\](red)";
    };

    directory = {
      format = "$path";
      truncation_length = 3;
      truncate_to_repo = true;
    };
  };
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/starship.toml".source = settings;
        ".config/fish/conf.d/starship.fish".text = lib.mkIf config.collinux.terminal.shells.fish.enable ''
          function starship_transient_prompt_func
            ${pkgs.starship}/bin/starship module character
          end

          if status is-interactive
            ${pkgs.starship}/bin/starship init fish | source
            enable_transience
          end
        '';
      };

      packages = [pkgs.starship];
    };
  }
