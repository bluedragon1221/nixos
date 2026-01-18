{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;

  mkCssHacks = hacks: hacks |> map (f: ''@import "${inputs.firefox-csshacks}/chrome/${f}.css";'') |> lib.concatStringsSep "\n";
in
  lib.mkIf cfg.enable {
    files = {
      ".mozilla/firefox/profiles.ini" = {
        generator = lib.generators.toINI {};
        value = {
          Profile0 = {
            Name = "collin";
            IsRelative = 1;
            Path = "collin";
            Default = 1;
          };
          General = {
            StartWithLastProfile = 1;
            Version = 2;
          };
        };
      };

      ".mozilla/firefox/collin/user.js".source = "${inputs.betterfox}/user.js";

      ".mozilla/firefox/collin/chrome/userChrome.css".text = mkCssHacks (
        # (lib.optional (cfg.theme == "adwaita") "window_control_placeholder_support") ++
        [
          # Tabs
          (
            if cfg.theme == "catppuccin"
            then "hide_tabs_with_one_tab"
            else "hide_tabs_with_one_tab_w_window_controls"
          )
          "tabs_on_bottom_v2"
          "tab_close_button_always_on_hover"
          "tabs_fill_available_width"

          # Icons!
          "iconized_main_menu"
          "iconized_menubar_items"
          "iconized_places_context_menu"
          "iconized_tabs_context_menu"
          "icon_only_context_menu_text_controls"

          # Other
          "compact_extensions_panel"
        ]
      );
    };

    packages = [pkgs.firefox];
  }
