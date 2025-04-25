{pkgs, ...}: {
  imports = [
    ../../system/battery.nix

    ../../system/nix.nix
    ../../system/fonts.nix
    ../../system/firefox.nix
    ../../system/desktops/hyprland.nix
  ];

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
