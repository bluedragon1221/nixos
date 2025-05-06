{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../system/bootloader.nix
    ../../system/desktops/gnome.nix
  ];

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  system.stateVersion = "25.05";
}
