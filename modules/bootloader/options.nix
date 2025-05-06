{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    collinux.boot = {
      theme = mkOption {
        type = types.enum ["catppuccin" "default"];
      };
      bootloader = mkOption {
        type = types.enum ["grub" "systemd-boot"];
      };
      plymouth.enable = mkEnableOption "plymouth bootsplash";
    };
  };
}
