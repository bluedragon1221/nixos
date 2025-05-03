{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../system/bootloader.nix
    ../../system/networking_iwd.nix

    ../../system/desktops/gnome.nix
  ];

  users = {
    mutableUsers = false;
    users.collin = {
      isNormalUser = true;
      shell = pkgs.bash;
      description = "Collin";
      extraGroups = ["networkmanager" "wheel"];
      hashedPassword = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };
  };

  system.stateVersion = "25.05";
}
