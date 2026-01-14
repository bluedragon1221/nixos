{
  pkgs,
  config,
  lib,
  my-lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  inherit (my-lib.options {inherit lib config;}) mkProgramOption mkThemeOption;
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
        internal = true;
      };

      greetd = {
        enable = mkEnableOption "greetd greeter";
        autologin.enable = mkEnableOption "autologin";
        cosmic-greeter.enable = mkEnableOption "cosmic-greeter";
      };
      gdm.enable = mkEnableOption "gdm display manager";

      wm = {
        sway.enable = mkEnableOption "sway";
        niri.enable = mkEnableOption "niri";

        components = {
          dunst = mkProgramOption "dunst";
          fuzzel = mkProgramOption "fuzzel";
        };
      };
      gnome.enable = mkEnableOption "gnome";

      gtk = {
        enable = mkEnableOption "gtk theming";
        theme = mkThemeOption "gtk";

        cursor_data = mkOption {
          internal = true;
          type = lib.types.submodule {
            options = {
              package = mkOption {
                internal = true;
                type = lib.types.package;
              };
              name = mkOption {
                internal = true;
                type = lib.types.str;
              };
            };
          };
          default =
            if config.collinux.desktop.gtk.theme == "catppuccin"
            then {
              name = "catppuccin-mocha-dark-cursors";
              package = pkgs.catppuccin-cursors.mochaDark;
            }
            else if config.collinux.gtk.theme == "adwaita"
            then {
              name = "Vanilla-DMZ";
              package = pkgs.vanilla-dmz;
            }
            else null;
        };

        theme_data = mkOption {
          internal = true;
          type = lib.types.submodule {
            options = {
              package = mkOption {
                internal = true;
                type = lib.types.package;
              };
              name = mkOption {
                internal = true;
                type = lib.types.str;
              };
            };
          };

          default =
            if config.collinux.desktop.gtk.theme == "catppuccin"
            then {
              package = pkgs.catppuccin-gtk.override {
                variant = "mocha";
                accents = ["blue"];
                size = "standard";
              };
              name = "catppuccin-mocha-blue-standard";
            }
            else if config.collinux.desktop.gtk.theme == "adwaita"
            then {
              package = pkgs.adw-gtk3;
              name = "adw-gtk3";
            }
            else null;
        };
      };

      programs = {
        firefox = {
          enable = mkEnableOption "firefox";
          profileName = mkOption {
            type = types.str;
            default = config.collinux.user.name;
            internal = true;
          };
          theme = mkThemeOption "firefox";
          extensions.zotero.enable = mkOption {
            description = "install Zotero Connector for Firefox";
            default = config.collinux.desktop.programs.research.enable;
          };
        };

        foot = mkProgramOption "foot";
        blackbox.enable = mkEnableOption "blackbox";
        ghostty.enable = mkEnableOption "ghostty";
        alacritty.enable = mkEnableOption "alacritty";

        research.enable = mkEnableOption "zathura, Xournal++, Zotero";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = with config.collinux.desktop; !(gdm.enable && greetd.enable);
        message = "Can't enable gdm and greetd at the same time";
      }
      {
        assertion = with config.collinux.desktop.greetd; enable && !(autologin.enable && cosmic-greeter.enable);
        message = "Can't use autologin and cosmic-greeter at the same time";
      }
    ];
  };
}
