{pkgs, ...}: {
  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    bambu-studio
    freecad-wayland
    gimp
    wine64
  ];

  home.stateVersion = "25.05";
}
