{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.bash;
in
  lib.mkIf cfg.enable {
    environment.etc = {
      "bashrc.local".text = ''
        if [ -s "''${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc" ]; then
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc"
        fi
      '';
    };
  }
