{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.eza;
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files =
        (lib.optionalAttrs config.collinux.terminal.shells.fish.enable {
          ".config/fish/conf.d/eza.fish".text = ''
            alias ls "eza -A -w 80 --group-directories-first -I '.git*'"
            alias tree "eza -T"
          '';
        })
        // (lib.optionalAttrs config.collinux.terminal.shells.fish.enable {
          ".config/bash/conf.d/eza.bash".text = ''
            alias ls="eza -A -w 80 --group-directories-first -I '.git*'"
            alias tree="eza -T"
          '';
        });

      packages = [pkgs.eza];
    };
  }
