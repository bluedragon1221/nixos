{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    collinux.boot = {
      systemd-boot.enable = mkEnableOption "systemd-boot";
      plymouth = {
        enable = mkEnableOption "plymouth bootsplash";
        theme = mkOption {
          type = types.enum ["catppuccin" "adwaita"];
          default = config.collinux.theme;
        };
      };
      secureBoot.enable = mkEnableOption "lanzaboote";
    };
  };
}
