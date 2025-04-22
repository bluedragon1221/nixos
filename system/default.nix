# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, pkgs, lib, ... }: {
  imports = [
    ./boot.nix
    ./autologin.nix
    ./vm.nix
    ./fs.nix
    ./audio.nix
    ./firefox.nix
  ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [
      (pkgs: super: {
        obsidian = pkgs.callPackage ../overlays/obsidian.nix {};
      })
    ];
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    allowed-users = ["@wheel"];
    allow-import-from-derivation = false; 
    use-xdg-base-directories = true;
  };

  # Hyprland (cfg in home-manager)
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  # Services
  networking.networkmanager.enable = true;

  ## Audio
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  ## ssh
  services.sshd.enable = false;

  # Users
  networking.hostName = "collinux";
  programs.command-not-found.enable = false; # gives errors unless you use nix channels (eww)

  users = {
    mutableUsers = false;
    users = {
      collin = {
        isNormalUser = true;
        shell = pkgs.fish;
        ignoreShellProgramCheck = true; # we install fish with home manager, so its fine
        description = "Collin";
        extraGroups = ["networkmanager" "wheel"];
        hashedPassword = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
      };
    };
  };

  environment.defaultPackages = lib.mkForce [];
  environment.systemPackages = with pkgs; [
    git
    blueman
    pwvucontrol
  ];

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      ibm-plex
      nerd-fonts.iosevka
    ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/home/collin/nixos2";
  };

  system.stateVersion = "25.05";
}

