{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin

    # Desktop
    ../../home/hyprland.nix
    ../../home/waybar
    ../../home/dunst.nix
    ../../home/gtk.nix

    # GUI
    ../../home/firefox.nix
    ../../home/fuzzel.nix
    ../../home/foot.nix

    # Term
    ../../home/shell.nix
    ../../home/helix.nix
    ../../home/git.nix
    ../../home/tmux
    ../../home/cmus
  ];

  programs.foot.settings.main.shell = "${pkgs.tmux}/bin/tmux";

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
