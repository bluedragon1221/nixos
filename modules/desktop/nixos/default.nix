{...}: {
  imports = [
    ./gnome.nix
    ./fonts.nix

    ./greeters/greetd.nix
    ./greeters/gdm.nix

    ./programs/firefox.nix
    ./programs/blackbox.nix
  ];
}
