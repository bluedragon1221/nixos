{pkgs, ...}: {
  packages = with pkgs; [
    orca-slicer
    freecad-wayland
    gimp
    qbittorrent
    bottles
    musescore
  ];
}
