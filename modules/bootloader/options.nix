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
        default =
          if (config.collinux.theme == "catppuccin")
          then "catppuccin"
          else "default";
      };
      bootloader = mkOption {
        type = types.enum ["grub" "systemd-boot"];
      };
      plymouth.enable = mkEnableOption "plymouth bootsplash";
    };
  };
}
