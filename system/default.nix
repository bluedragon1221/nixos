{ inputs, pkgs, lib, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ./locale.nix
    ./greetd.nix
  ];

  # Bootloader
  boot = {
    initrd.verbose = false;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    plymouth = {
      enable = true;
      theme = "catppuccin-macchiato";
      themePackages = [ pkgs.catppuccin-plymouth ];
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    allowed-users = [ "@wheel" ];
    allow-import-from-derivation = false;
    use-xdg-base-directories = true; # gets rid of .nix-* directories in $HOME
  };

  # Hyprland (cfg in home-manager)
  programs.hyprland.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Services
  networking.networkmanager.enable = true;

  ## Audio
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  services.sshd.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };

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
        extraGroups = [ "networkmanager" "wheel" ];
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
  environment.systemPackages = with pkgs; [
    musescore
    nuclear
    # obsidian
    kdePackages.kleopatra

    # fr33zmenu
    hover-rs
    my-kitty
    my-firefox

    cargo
    hyprcursor

    my-cmus
    my-cava
  ] ++ [ inputs.zen-browser.packages."${system}".default ];

  fonts = {
    enableDefaultPackages = false;
    packages = [ pkgs.ibm-plex ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/etc/nixos";
  };

  system.stateVersion = "24.05";
}
