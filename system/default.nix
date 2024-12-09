{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ./locale.nix
    ./greetd.nix
  ];

  # Bootloader
  boot = {
    initrd.verbose = false;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    plymouth = {
      enable = true;
      theme = "catppuccin-macchiato";
      themePackages = [pkgs.catppuccin-plymouth];
    };
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    allowed-users = ["@wheel"];
    allow-import-from-derivation = false;
    use-xdg-base-directories = true; # gets rid of .nix-* directories in $HOME
    auto-optimise-store = true; # makes nix store more efficient
  };

  # Hyprland (cfg in home-manager)
  programs.hyprland.enable = true;

  # Services
  networking.networkmanager.enable = true;

  ## Audio
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = false;
    wireplumber.enable = true;
    alsa.enable = true;
  };

  services.printing.enable = false;
  services.sshd.enable = true;

  # Users
  networking.hostName = "collinux";
  programs.command-not-found.enable = false;

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.bash;
    users = {
      collin = {
        isNormalUser = true;
        description = "Collin";
        extraGroups = ["networkmanager" "wheel"];
        hashedPassword = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
      };

      # ssh demo
      bob = {
        isNormalUser = true;
        description = "Bob";
        hashedPassword = "$y$j9T$uYADjl9Jv3IN6xrKyIqy11$gCIa0bHsuDO4IRyVlhq45wO8oHf7.BaAq4pDc.fKbVD";
      };
    };
  };

  environment.defaultPackages = lib.mkForce [];
  environment.systemPackages = with pkgs;
    [
      musescore
      nuclear
      # obsidian
      kdePackages.kleopatra

      hover-rs

      cargo

      my-cmus
      my-cava
      pwvucontrol
    ]
    ++ [
      inputs.zen-browser.packages.${system}.default
    ];

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      ibm-plex
      scientifica
      nerd-fonts.iosevka
      # (pkgs.nerdfonts.override {fonts = ["Iosevka"];})
    ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/home/collin/nixos";
  };

  system.stateVersion = "24.05";
}
