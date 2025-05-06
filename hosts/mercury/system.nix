{pkgs, ...}: {
  imports = [
    ../../system/battery.nix

    ../../system/fonts.nix

    ../../system/nix.nix

    ../../system/bluetooth.nix
    ../../system/audio.nix
  ];

  services.blueman.enable = true;

  system.stateVersion = "25.05";
}
