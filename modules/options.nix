{lib, ...}: let
  inherit (lib) mkOption types;
in {
  imports = [
    ./firefox
    ./terminal
    ./gtk
  ];

  options = {
    collinux = {
      username = mkOption {
        type = types.str;
      };

      theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
      };
    };
  };
}
