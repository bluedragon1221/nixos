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
      bcache.enable = false; # why is this default on? I DON'T CARE ABOUT bcache
      initrd = {
        verbose = false;
        systemd.enable = true;
        checkJournalingFS = false;
      };
      loader = {
        systemd-boot = lib.optionalAttrs (cfg.systemd-boot.enable && !cfg.secureBoot.enable) {
          enable = true;
          configurationLimit = 3;
        };
        efi.canTouchEfiVariables = true;
        timeout = cfg.timeout; # hold space to show boot menu
      };
    }
    // (lib.optionalAttrs cfg.secureBoot.enable {
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    });

  system.etc.overlay.enable = true;
  system.nixos-init.enable = true;

  environment.systemPackages =
    (
      if cfg.secureBoot.enable
      then [pkgs.sbctl]
      else []
    )
    ++ [pkgs.efibootmgr];
}
