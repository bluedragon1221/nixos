{
  lib,
  config,
  ...
}: {
  imports = [
    ./gtk
  ];

  qt.style = lib.optionalAttrs (config.collinux.theme == "adwaita") {name = "adwaita-dark";};
}
