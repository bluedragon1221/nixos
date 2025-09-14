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
    };
  }
