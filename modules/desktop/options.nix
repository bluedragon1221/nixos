{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
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
          waybar.enable = mkEnableOption "waybar";
          dunst.enable = mkEnableOption "dunst";
          fuzzel.enable = mkEnableOption "fuzzel";
        };
      };
      gnome.enable = mkEnableOption "gnome";
      # shortcuts = mkOption {
      #   type = types.listOf types.submodule {
      #     key = mkOption {
      #       type = types.str;
      #     };
      #     command = mkOption {
      #       type = types.str;
      #     };
      #   };
      # };
    };
  };
}
