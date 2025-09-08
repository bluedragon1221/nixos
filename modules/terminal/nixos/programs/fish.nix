{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/fish/config.fish".text = ''
          set fish_greeting

          function fish_title
              echo fish (prompt_pwd)
          end

          direnv hook fish | source
          pay-respects fish --alias | source
        '';
      };

      packages = with pkgs; [
        fish
        ripgrep
        fd
        moreutils
        zip
        unzip
        btop
        jq
        direnv
        pay-respects
      ];
    };
  }
