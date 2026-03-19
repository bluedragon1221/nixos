{...}: {
  imports = [
    ./gnome.nix
    ./fonts.nix
    ./portals.nix
    ./qt.nix

    ./greeters/greetd.nix
    ./greeters/gdm.nix

    ./programs/firefox.nix
    ./programs/blackbox.nix
  ];
}
