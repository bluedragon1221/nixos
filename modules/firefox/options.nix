{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    collinux.firefox = {
      enable = mkEnableOption "firefox";
      profileName = mkOption {
        type = types.str;
        default = config.collinux.user.name;
      };
      theme = mkOption {
        type = types.enum ["none" "catppuccin" "adwaita"];
        default = config.collinux.theme;
      };
    };
  };
}
