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
      files.".config/fish/conf.d/bat.fish".text = ''
        alias cat bat
        set -gx BAT_THEME "base16"
      '';

      packages = [pkgs.bat];
    };
  }
