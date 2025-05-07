{pkgs, ...}: {
  imports = [
    ../../home/nh.nix
  ];

  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    bambu-studio
    freecad-wayland
    gimp
  ];

  home.stateVersion = "25.05";
}
