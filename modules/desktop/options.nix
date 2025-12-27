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
      wallpaper_cmd = mkOption {
        type = types.str;
        default = "${lib.getExe pkgs.wbg} -s ${config.collinux.desktop.wallpaper}";
      };

      greetd = {
        enable = mkEnableOption "greetd greeter";
        command = mkOption {
          type = lib.types.str;
          default = let
            cfg = config.collinux.desktop;
          in
            if (cfg.wm.sway.enable && !cfg.gnome.enable && !cfg.wm.niri.enable)
            then lib.getExe pkgs.sway
            else if (cfg.wm.niri.enable && !cfg.gnome.enable && !cfg.wm.sway.enable)
            then "${pkgs.niri}/bin/niri-session"
            else null;
        };
      };
      gdm.enable = mkEnableOption "gdm display manager";

      wm = {
        sway.enable = mkEnableOption "sway";
        niri.enable = mkEnableOption "niri";

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
          type = types.enum ["catppuccin" "adwaita" "kanagawa"];
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
            type = types.enum ["none" "catppuccin" "adwaita" "kanagawa"];
            default = config.collinux.theme;
          };
          extensions.zotero.enable = mkOption {
            description = "install Zotero Connector for Firefox";
            default = config.collinux.desktop.programs.research.enable;
          };
        };

        foot = mkProgramOption "foot";
        blackbox.enable = mkEnableOption "blackbox";
        ghostty.enable = mkEnableOption "ghostty";
        alacritty.enable = mkEnableOption "alacritty";

        research.enable = mkEnableOption "zathura, Xournal++, Zotero, Zotero Connector";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = with config.collinux.desktop; !(gdm.enable && greetd.enable);
        message = "Can't enable gdm and greetd at the same time";
      }
    ];
  };
}
