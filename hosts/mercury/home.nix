{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Desktop
    ../../home/hyprland.nix
    ../../home/waybar
    ../../home/dunst.nix

    # GUI
    ../../home/fuzzel.nix

    # Term
    ../../home/nh.nix
    ../../home/cmus
  ];

  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    # GUI apps
    musescore
    obsidian
    kdePackages.kleopatra
    mpv
  ];

  home.stateVersion = "25.05";
}
