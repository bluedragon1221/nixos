{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;

  mkProgramOption' = name: extraOpts:
    {
      enable = mkEnableOption "whether to enable ${name}";
      theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
        default = config.collinux.terminal.theme;
      };
    }
    // extraOpts;

  mkProgramOption = name: mkProgramOption' name {};
in {
  options = {
    collinux.desktop = {
      greeter = mkOption {
        type = types.enum ["gdm" "greetd"];
        default = let
          cfg = config.collinux.desktop;
        in
          if (cfg.hyprland.enable && !cfg.gnome.enable)
          then "greetd"
          else "gdm";
      };

      hyprland = {
        enable = mkEnableOption "hyprland";
        useUwsm = mkOption {
          type = types.bool;
        };
        components = {
          waybar = mkProgramOption "waybar";
          dunst = mkProgramOption "dunst";
          fuzzel = mkProgramOption "fuzzel";
        };
      };
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

        musescore.enable = mkEnableOption "musescore";
      };
    };
  };
}
