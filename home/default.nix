{ pkgs, inputs, ... }: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./hyprland.nix
    ./helix.nix
    ./foot.nix
    ./shell.nix
    ./git.nix
    ./firefox.nix
    ./gtk.nix
    ./waybar
  ];

  catppuccin.flavor = "mocha";

  home.packages = with pkgs; [
    musescore
    obsidian
    kdePackages.kleopatra
    mpv
  ];
  home.preferXdgDirectories = true;

  home.stateVersion = "25.05";
}
