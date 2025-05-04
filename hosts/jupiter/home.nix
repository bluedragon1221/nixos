{pkgs, ...}: {
  home.preferXdgDirectories = true;
  # home.packages = with pkgs; [
  #   bambu-studio
  #   bottles
  #   musescore
  #   obsidian
  #   nicotine-plus
  #   freecad-wayland
  # ];

  home.stateVersion = "25.05";
}
