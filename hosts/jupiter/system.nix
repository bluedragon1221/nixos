{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../system/nix.nix

    ../../system/bluetooth.nix
    ../../system/audio.nix
  ];

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  system.stateVersion = "25.05";
}
