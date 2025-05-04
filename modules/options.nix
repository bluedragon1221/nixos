{lib, ...}: let
  inherit (lib) mkOption types;
in {
  imports = [
    ./firefox/options.nix
    ./terminal/options.nix
    ./gtk/options.nix
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
