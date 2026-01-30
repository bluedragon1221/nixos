{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.system.boot;
in {
  boot =
    {
      bcache.enable = false; # why is this default on? I DON'T CARE ABOUT bcachefs
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
        timeout = cfg.timeout; # hold space to show boot menu if timeout == 0
      };

      plymouth = lib.mkIf cfg.plymouth.enable {
        enable = true;
        theme =
          if (cfg.plymouth.theme == "catppuccin")
          then "catppuccin-macchiato" # for whatever reason catppuccin-mocha has errors
          else "nixos-bgrt";
        themePackages =
          if (cfg.plymouth.theme == "catppuccin")
          then [pkgs.catppuccin-plymouth]
          else [pkgs.nixos-bgrt-plymouth];
      };

      # from hardened.nix
      blacklistedKernelModules = [
        # Obscure network protocols
        "ax25"
        "netrom"
        "rose"

        # Old or rare or insufficiently audited filesystems
        "adfs"
        "affs"
        "bfs"
        "befs"
        "cramfs"
        "efs"
        # "erofs" # necessary for system.etc.overlay
        "exofs"
        "freevxfs"
        "f2fs"
        "hfs"
        "hpfs"
        "jfs"
        "minix"
        "nilfs2"
        "ntfs"
        "omfs"
        "qnx4"
        "qnx6"
        "sysv"
        "ufs"
      ];
    }
    // (lib.optionalAttrs cfg.secureBoot.enable {
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    });

  system.etc.overlay = {
    enable = true;
    mutable = true; # would love this to be false, but we're not there yet
  };
  system.nixos-init.enable = true;

  # store journald logs in memory
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=100M
  '';

  environment.systemPackages = [pkgs.efibootmgr] ++ lib.optional cfg.secureBoot.enable pkgs.sbctl;
}
