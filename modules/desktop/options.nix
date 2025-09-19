{
  pkgs,
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
      wallpaper = mkOption {
        type = with types; oneOf [str path];
        description = "File to use as the wallpaper on this machine";
      };

      greetd = {
        enable = mkEnableOption "greetd greeter";
        command = mkOption {
          type = lib.types.package;
          default = let
            cfg = config.collinux.desktop;
          in
            if (cfg.sway.enable && !cfg.gnome.enable)
            then pkgs.sway
            else null;
        };
      };
      gdm.enable = mkEnableOption "gdm display manager";

      sway = {
        enable = mkEnableOption "sway";
        components = {
          # waybar = mkProgramOption "waybar";
          dunst = mkProgramOption "dunst";
          fuzzel = mkProgramOption "fuzzel";
        };
      };
      gnome.enable = mkEnableOption "gnome";

      gtk = {
        enable = mkEnableOption "gtk theming";
        theme = mkOption {
          type = types.enum ["catppuccin" "adwaita"];
          default = config.collinux.theme;
        };
        cursor_data = {
          package = mkOption {
            type = lib.types.package;
            default =
              if (config.collinux.desktop.gtk.theme == "catppuccin")
              then pkgs.catppuccin-cursors.mochaDark
              else if (config.collinux.desktop.gtk.theme == "adwaita")
              then pkgs.vanilla-dmz
              else null;
          };
          name = mkOption {
            type = lib.types.str;
            default =
              if (config.collinux.desktop.gtk.theme == "catppuccin")
              then "catppuccin-mocha-dark-cursors"
              else if (config.collinux.desktop.gtk.theme == "adwaita")
              then "Vanilla-DMZ"
              else null;
          };
        };
        theme_data = {
          package = mkOption {
            type = lib.types.package;
            default =
              if (config.collinux.desktop.gtk.theme == "catppuccin")
              then
                (pkgs.catppuccin-gtk.override {
                  variant = "mocha";
                  accents = ["blue"];
                  size = "standard";
                })
              else if (config.collinux.desktop.gtk.theme == "adwaita")
              then pkgs.adw-gtk3
              else "";
          };
          name = mkOption {
            type = lib.types.str;
            default =
              if (config.collinux.desktop.gtk.theme == "catppuccin")
              then "catppuccin-mocha-blue-standard"
              else if (config.collinux.desktop.gtk.theme == "adwaita")
              then "adw-gtk3"
              else "";
          };
        };
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
          extensions.zotero.enable = mkOption {
            description = "install Zotero Connector for Firefox";
            default = config.collinux.desktop.programs.research.enable;
          };
        };

        foot.enable = mkEnableOption "foot";
        blackbox.enable = mkEnableOption "blackbox";
        alacritty.enable = mkEnableOption "alacritty";

        research.enable = mkEnableOption "zathura, Xournal++, Zotero, Zotero Connector";
      };
    };
  };
}
