{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.boot;
in {
  boot =
    {
      initrd = {
        verbose = false;
        systemd.enable = true;
      };
      loader = {
        systemd-boot = lib.mkIf (cfg.bootloader == "systemd-boot" && !cfg.secureBoot.enable) {
          enable = true;
          configurationLimit = 3;
        };
        grub = lib.mkIf (cfg.bootloader == "grub") {
          enable = true;
        };
        efi.canTouchEfiVariables = true;
        timeout = 0;
      };

      plymouth = lib.mkIf cfg.plymouth.enable {
        enable = true;
        theme =
          if (cfg.theme == "catppuccin")
          then "catppuccin-macchiato" # for whatever reasom catppuccin-mocha has build errors
          else "nixos-bgrt";
        themePackages =
          if (cfg.theme == "catppuccin")
          then [pkgs.catppuccin-plymouth]
          else [pkgs.nixos-bgrt-plymouth];
      };
    }
    // (
      if cfg.secureBoot.enable
      then {
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      }
      else {}
    );

  environment.systemPackages = lib.mkIf cfg.secureBoot.enable [pkgs.sbctl];
}
