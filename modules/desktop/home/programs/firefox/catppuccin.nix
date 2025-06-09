{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;
in
  lib.mkIf (cfg.enable && cfg.theme == "catppuccin") {
    programs.firefox.profiles."${cfg.profileName}".settings = {
      "browser.compactmode.show" = true;
      "browser.uidensity" = 1;

      "browser.tabs.inTitlebar" = 0;
      "sidebar.verticalTabs" = true;
      "sidebar.main.tools" = "";

      "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":[],"nav-bar":["sidebar-button","customizableui-special-spring4","back-button","forward-button","urlbar-container","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","unified-extensions-button","vertical-spacer"],"toolbar-menubar":["menubar-items"],"TabsToolbar":[],"vertical-tabs":["tabbrowser-tabs"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"],"dirtyAreaCache":["nav-bar","TabsToolbar","vertical-tabs","PersonalToolbar","toolbar-menubar","unified-extensions-area"],"currentVersion":21,"newElementCount":6}'';
      "browser.uiCustomization.navBarWhenVerticalTabs" = ''["sidebar-button","customizableui-special-spring4","back-button","forward-button","urlbar-container","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","unified-extensions-button","vertical-spacer"]'';
    };
  }
