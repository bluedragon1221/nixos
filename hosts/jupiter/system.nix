{pkgs, inputs, ...}: {
  imports = [
    ./disks.nix 

    ../../system/bootloader.nix
    ../../system/audio.nix
    ../../system/bluetooth.nix

    ../../system/nix.nix
    ../../system/fonts.nix
    ../../system/firefox.nix
    ../../system/desktops/gnome.nix
  ];

  
}
