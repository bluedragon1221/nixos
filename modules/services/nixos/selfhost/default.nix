{
  lib,
  config,
  ...
}: {
  imports = [
    ./navidrome.nix
  ];

  qt.style = lib.optionalAttrs (config.collinux.theme == "adwaita") {name = "adwaita-dark";};
}
