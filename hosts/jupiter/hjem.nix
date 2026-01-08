{pkgs, ...}: {
  packages = with pkgs; [
    gimp
    qbittorrent
    bottles

    vital
    musescore
    qpwgraph
  ];
}
