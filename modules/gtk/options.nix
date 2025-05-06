{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux.gtk.theme = mkOption {
      type = types.enum ["catppuccin" "adwaita"];
      default = config.collinux.theme;
    };
  };
}
