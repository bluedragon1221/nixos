{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home/terminal

    # Desktop
    ../../home/hyprland.nix
    ../../home/waybar
    ../../home/dunst.nix
    ../../home/gtk.nix

    # GUI
    ../../home/fuzzel.nix
    ../../home/foot.nix

    # Term
    ../../home/git.nix
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
