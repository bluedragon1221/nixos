{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.starship;

  settings = {
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
      files =
        {
          ".config/starship.toml" = {
            generator = (pkgs.formats.toml {}).generate "starship.toml";
            value = settings;
          };
        }
        // (lib.optionalAttrs config.collinux.terminal.shells.fish.enable {
          ".config/fish/conf.d/starship.fish".text = ''
            function starship_transient_prompt_func
              starship module character
            end

            starship init fish | source
            enable_transience
          '';
        })
        // (lib.optionalAttrs config.collinux.terminal.shells.bash.enable {
          ".config/bash/conf.d/starship.bash".text = ''
            eval "$(starship init bash)"
          '';
        });

      packages = [pkgs.starship];
    };
  }
