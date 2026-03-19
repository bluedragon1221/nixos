{pkgs, ...}: {
  imports = [
    ./dunst.nix
    ./fuzzel.nix
    ./niri.nix
    ./sway.nix
    ./tofi.nix
  ];

  packages = [
    (pkgs.callPackage ../../../../pkgs/util {}) # util.lua
  ];
}
