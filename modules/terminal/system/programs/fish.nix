{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;

  init = ''
    set fish_greeting

    function fish_title
        echo fish (prompt_pwd)
    end

    direnv hook fish | source
    pay-respects fish --alias | source
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/fish/config.fish".text = init;
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
