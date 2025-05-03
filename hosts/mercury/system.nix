{pkgs, ...}: {
  imports = [
    ../../system/battery.nix
    # ../../system/networking.nix
    ../../system/networking_iwd.nix

    ../../system/fonts.nix
    ../../system/desktops/hyprland.nix
  ];

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [foot.terminfo];

  services.sshd.enable = true;

  users = {
    mutableUsers = false;
    users.collin = {
      isNormalUser = true;
      shell = pkgs.fish;
      ignoreShellProgramCheck = true; # we install fish through home-manager
      description = "Collin";
      extraGroups = ["networkmanager" "wheel"];
      hashedPassword = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };
  };

  system.stateVersion = "25.05";
}
