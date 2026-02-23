{
  imports = [
    ./caddy.nix
    ./openssh.nix

    ./forgejo.nix
    ./goaccess.nix

    ./cgit
    ./polaris.nix
    # ./mopidy.nix
    # ./jellyfin.nix
    ./copyparty.nix
    ./qbittorrent.nix
  ];
}
