{
  my-lib,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
  inherit (my-lib.options {inherit lib config;}) mkThemeOption;
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
        theme = mkThemeOption "plymouth";
      };
      secureBoot.enable = mkEnableOption "lanzaboote";
    };
  };
}
