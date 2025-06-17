{pkgs, ...}: {
  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    orca-slicer
    freecad-wayland
    gimp
    qbittorrent
    bottles
    musescore
  ];

  home.stateVersion = "25.05";
}
