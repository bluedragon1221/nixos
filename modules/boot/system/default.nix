{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.boot;
in {
  imports = [
    ./plymouth.nix
  ];

  boot =
    {
      initrd = {
        verbose = false;
        systemd.enable = true;
      };
      loader = {
        systemd-boot = lib.optionalAttrs (cfg.bootloader == "systemd-boot" && !cfg.secureBoot.enable) {
          enable = true;
          configurationLimit = 3;
        };
        grub = lib.optionalAttrs (cfg.bootloader == "grub") {enable = true;};
        efi.canTouchEfiVariables = true;
        timeout = 0;
      };
    }
    // (lib.optionalAttrs cfg.secureBoot.enable {
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    });

  environment.systemPackages = lib.mkIf cfg.secureBoot.enable [pkgs.sbctl];
}
