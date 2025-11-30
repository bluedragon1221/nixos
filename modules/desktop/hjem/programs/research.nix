{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.programs.research;
in
  lib.mkIf cfg.enable {
    packages = with pkgs; [
      zotero
      zathura
      xournalpp
      ocrmypdf
    ];
    files = {
      ".config/xournalpp/toolbar.ini" = {
        generator = lib.generators.toINI {};
        value = {
          "Default" = {
            toolbarTop1 = "ERASER,PEN,HIGHLIGHTER,SELECT_PDF_TEXT_LINEAR,SEPARATOR,TEXT,MATH_TEX,IMAGE,SPACER,FINE,MEDIUM,THICK,VERY_THICK,SEPARATOR,SELECT_FONT,COLOR(6),COLOR(8),COLOR(9),COLOR(3),COLOR(2),COLOR(4),COLOR(7),COLOR(5),COLOR(0),SEPARATOR";
            name = "Default";
          };
        };
      };

      ".config/zathura/zathurarc".text = lib.mkIf (config.collinux.theme == "adwaita") ''
        set font "Iosevka Nerd Font 11.5"

        set recolor 'true'
        set recolor-keephue 'false'
        set recolor-reverse-video 'false'

        # flipped to make dark mode
        set recolor-lightcolor rgba(0,0,0,0)
        set recolor-darkcolor '#DEDDDA'

        set completion-fg '#DEDDDA'
        set completion-bg '#303030'
        set completion-group-fg '#33B2A4'
        set completion-group-bg '#303030'
        set completion-highlight-fg '#303030'
        set completion-highlight-bg '#DEDDDA'

        set default-fg '#DEDDDA'
        set default-bg rgba(29,29,29,0.6)

        set inputbar-fg '#DEDDDA'
        set inputbar-bg '#303030'

        set notification-fg '#DEDDDA'
        set notification-bg '#303030'
        set notification-error-fg '#DEDDDA'
        set notification-error-bg '#E01B24'
        set notification-warning-fg '#DEDDDA'
        set notification-warning-bg '#E01B24'

        set statusbar-fg '#DEDDDA'
        set statusbar-bg '#303030'

        set highlight-color '#33B2A4'
        set highlight-active-color '#33B2A4'

        set render-loading-fg '#DEDDDA'
        set render-loading-bg '#303030'

        set index-fg '#DEDDDA'
        set index-bg '#303030'
        set index-active-fg '#303030'
        set index-active-bg '#DEDDDA'
      '';
    };
  }
