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
      timeout = mkOption {
        description = "bootloader timeout";
        type = lib.types.int;
        default = 0;
      };
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
