{pkgs, ...}: {
  imports = [
    ./emulators/blackbox.nix # can't do dbus with hjem
  ];
}
