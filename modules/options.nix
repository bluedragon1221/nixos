{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux.theme = mkOption {
      type = types.enum ["catppuccin" "adwaita"];
    };
  };
}
