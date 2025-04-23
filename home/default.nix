{ pkgs, inputs, ... }: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./hyprland.nix
    ./helix.nix
    ./foot.nix
    ./fuzzel.nix
    ./shell.nix
    ./git.nix
    ./firefox.nix
    ./cmus
    ./gtk.nix
    ./dunst.nix
    ./waybar
  ];

  catppuccin.flavor = "mocha";

  home.packages = with pkgs; [
    musescore
    obsidian
    kdePackages.kleopatra
    mpv
    btop
    wl-clipboard
  ];
  home.preferXdgDirectories = true;

  home.stateVersion = "25.05";
}
