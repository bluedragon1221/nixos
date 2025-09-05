{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.bat;
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files =
        (lib.optionalAttrs config.collinux.terminal.shells.fish.enable {
          ".config/fish/conf.d/bat.fish".text = ''
            alias cat bat
            set -gx BAT_THEME "base16"
          '';
        })
        // (lib.optionalAttrs config.collinux.terminal.shells.bash.enable {
          ".config/fish/conf.d/bat.bash".text = ''
            alias cat="bat"
            export BAT_THEME="base16"
          '';
        });

      packages = [pkgs.bat];
    };
  }
