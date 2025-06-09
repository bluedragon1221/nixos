{
  config,
  lib,
  my-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  inherit (my-lib.options {inherit lib config;}) mkProgramOption;
in {
  options = {
    collinux.desktop = {
      greeter = mkOption {
        type = types.enum ["gdm" "greetd"];
        default = let
          cfg = config.collinux.desktop;
        in
          if (cfg.sway.enable && !cfg.gnome.enable)
          then "greetd"
          else "gdm";
      };

      wallpaper = mkOption {
        type = types.path;
      };

      components = {
        waybar = mkProgramOption "waybar";
        dunst = mkProgramOption "dunst";
        fuzzel = mkProgramOption "fuzzel";
      };

      sway.enable = mkEnableOption "sway";
      gnome.enable = mkEnableOption "gnome";

      gtk.theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
        default = config.collinux.theme;
      };

      programs = {
        firefox = {
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

        foot.enable = mkEnableOption "foot";
        blackbox.enable = mkEnableOption "blackbox";
      };
    };
  };
}
