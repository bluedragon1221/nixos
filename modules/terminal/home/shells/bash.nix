{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.bash;
in
  lib.mkIf cfg.enable {
    home.shell.enableBashIntegration = true;
    programs.bash = {
      enable = true;
      enableVteIntegration = true;
    };
  }
