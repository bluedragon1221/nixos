{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../system/bootloader.nix
    ../../system/networking.nix # apparently gnome only supports networkmanager

    ../../system/desktops/gnome.nix
  ];

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  system.stateVersion = "25.05";
}
