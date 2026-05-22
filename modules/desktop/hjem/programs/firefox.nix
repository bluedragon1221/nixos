{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;

  mkCssHacks = hacks: hacks |> map (f: ''@import "${inputs.firefox-csshacks}/chrome/${f}.css";'') |> lib.concatStringsSep "\n";

  profileDir = ".config/mozilla/firefox/collin";
in
  lib.mkIf cfg.enable {
    files = {
      ".config/mozilla/firefox/profiles.ini" = {
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

      "${profileDir}/user.js".source = "${inputs.betterfox}/user.js";

      "${profileDir}/chrome/utils".source = "${inputs.fx-autoconfig}/profile/chrome/utils";

      "${profileDir}/chrome/JS/test.uc.js".source = "${inputs.fx-autoconfig}/profile/chrome/JS/test.uc.js";

      "${profileDir}/chrome/JS/aboutCfg.sys.mjs".source = "${inputs.uc-css-js}/JS/aboutCfg.sys.mjs";

      "${profileDir}/chrome/JS/aboutUserChrome.sys.mjs".source = "${inputs.uc-css-js}/JS/aboutUserChrome.sys.mjs";
      "${profileDir}/chrome/resources/aboutuserchrome".source = "${inputs.uc-css-js}/resources/aboutuserchrome";

      "${profileDir}/chrome/JS/appMenuMods.uc.js".source = "${inputs.uc-css-js}/JS/appMenuMods.uc.js";

      "${profileDir}/chrome/userChrome.css".text = mkCssHacks [
        # Tabs
        "hide_tabs_with_one_tab"
        "tabs_on_bottom_v2"
        "tab_close_button_always_on_hover"
        "tabs_fill_available_width"

        # Icons!
        "iconized_main_menu"
        "iconized_places_context_menu"
        "iconized_tabs_context_menu"
        "icon_only_context_menu_text_controls"

        # Other
        "compact_extensions_panel"
      ];
    };
  }
