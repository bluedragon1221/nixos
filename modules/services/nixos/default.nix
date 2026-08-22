{
  imports = [
    ./caddy.nix
    ./openssh.nix

    ./goaccess.nix
    ./btopweb.nix
    ./cgit
    ./ganyupload
    ./jta
    ./glance.nix
    ./filebrowser.nix

    ./minecraft.nix
    ./ngircd.nix
    ./qbittorrent.nix
  ];

  users.groups."fileserver" = {};
}
