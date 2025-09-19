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
