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

         export HISTFILE="$XDG_STATE_HOME"/bash/history
         alias wget="wget --hsts-file /dev/null"
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
