{
  lib,
  my-lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
  inherit (my-lib.options {inherit lib config;}) mkThemeOption;
in {
  options.collinux.system = {
    boot = {
      systemd-boot.enable = mkOption {
        description = "Whether to use systemd-boot on this system";
        default = true;
      };
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

    audio.enable = mkEnableOption "pipewire and wireplumber";
    bluetooth.enable = mkEnableOption "bluetooth";
    printing.enable = mkEnableOption "cups printing server";
  };
}
