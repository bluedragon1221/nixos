{pkgs, ...}: {
  packages = with pkgs; [
    orca-slicer
    bambu-studio

    freecad-wayland
    gimp
    qbittorrent
    bottles

    vital
    musescore
    helvum
  ];
}
