{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.bash;
in
  lib.mkIf cfg.enable {
    files = {
      ".config/bash/bashrc".text = ''
        eval "$(direnv hook bash)"

        for file in ~/.config/bash/conf.d/*; do source "$file"; done
      '';
    };

    packages = with pkgs; [
      fish
      ripgrep
      fd
      wget
      moreutils
      zip
      unzip
      btop
      jq
      direnv
    ];
  }
