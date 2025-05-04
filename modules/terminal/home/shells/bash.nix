{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    collinux.terminal.shells.bash = {
      enable = lib.mkEnableOption "configuration of the bash shell";
    };
  };

  config = let
    cfg = config.collinux.terminal.shells.bash;
  in
    lib.mkIf cfg.enable {
      home.shell.enableBashIntegration = true;
      programs.bash = {
        enable = true;
        enableVteIntegration = true;
      };
    };
}
