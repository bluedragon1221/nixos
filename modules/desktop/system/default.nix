{...}: {
  imports = [
    ./environments/gnome.nix
    ./environments/sway.nix

    ./programs/firefox.nix
    ./programs/foot.nix
    ./programs/blackbox.nix

    ./components/fuzzel.nix
    ./components/dunst.nix
  ];
}
