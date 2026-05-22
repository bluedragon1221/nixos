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
        autologin = {
          enable = mkEnableOption "autologin";
          command = mkOption {
            internal = true;
            type = lib.types.str;
            default = with config.collinux.desktop;
              if (wm.sway.enable && !gnome.enable && !wm.niri.enable)
              then "${pkgs.sway}/bin/sway"
              else if (wm.niri.enable && !gnome.enable && !wm.sway.enable)
              then "${pkgs.niri}/bin/niri-session"
              else null;
          };
        };
        cosmic-greeter.enable = mkEnableOption "cosmic-greeter";
      };
      gdm.enable = mkEnableOption "gdm display manager";

      wm = {
        sway.enable = mkEnableOption "sway";
        niri.enable = mkEnableOption "niri";

        gtkDesktopPortal.enable = mkEnableOption "GTK desktop portal backend";
        kdeDesktopPortal.enable = mkEnableOption "KDE desktop portal backend";

        components = {
          dunst = mkProgramOption "dunst";
          fuzzel = mkProgramOption "fuzzel";
          tofi = mkProgramOption "tofi";
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
            else if config.collinux.desktop.gtk.theme == "adwaita"
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

      qt = {
        enable = mkEnableOption "qt theming";
        theme = mkThemeOption "qt";
        iconTheme = mkOption {
          type = types.str;
          default = "Papirus";
          description = "Icon theme to use for Qt/KDE applications";
        };
      };

      programs = {
        firefox = {
          enable = mkEnableOption "firefox";
          theme = mkThemeOption "firefox";
          extensions.foxyproxy.enable = mkEnableOption "install FoxyProxy extension";
        };

        foot = mkProgramOption "foot";
        blackbox.enable = mkEnableOption "blackbox";
        ghostty.enable = mkEnableOption "ghostty";
        alacritty.enable = mkEnableOption "alacritty";

        research.enable = mkEnableOption "zathura, Xournal++";
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
        assertion = with config.collinux.desktop.greetd; enable -> !(autologin.enable && cosmic-greeter.enable);
        message = "Can't use autologin and cosmic-greeter at the same time";
      }
      {
        assertion = with config.collinux.desktop.wm; !(gtkDesktopPortal.enable && kdeDesktopPortal.enable);
        message = "Can't enable GTK and KDE desktop portal backends at the same time";
      }
    ];
  };
}
