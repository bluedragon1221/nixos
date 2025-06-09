{...}: {
  imports = [
    ./environments/gnome.nix
    ./environments/sway.nix

    ./programs/firefox.nix
    ./programs/foot.nix

    ./components/fuzzel.nix
    ./components/dunst.nix
  ];
}
