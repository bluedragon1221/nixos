{pkgs, ...}: {
  programs.firefox = {
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        PasswordManagerEnabled = false;
        DisableAccounts = true;
        DisablePocket = true;

        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";

        ExtensionSettings = let
          ext = name: {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
          };
        in {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = ext "bitwarden-password-manager";
          "{88b098c8-19be-421e-8ffa-85ddd1f3f004}" = ext "catppuccin-mocha-blue";
          "uBlock0@raymondhill.net" = ext "uBlock0@raymondhill.net";
        };
      };
    };

    enable = true;
    profiles."collin" = {
      isDefault = true;

      search.default = "ddg";

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.toolbars.bookmarks.visibility" = "never";

        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;

        "browser.urlbar.groupLabels.enabled" = false;

        "browser.tabs.inTitlebar" = 0;
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "";

        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":[],"nav-bar":["sidebar-button","customizableui-special-spring4","back-button","forward-button","urlbar-container","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","unified-extensions-button","vertical-spacer"],"toolbar-menubar":["menubar-items"],"TabsToolbar":[],"vertical-tabs":["tabbrowser-tabs"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"],"dirtyAreaCache":["nav-bar","TabsToolbar","vertical-tabs","PersonalToolbar","toolbar-menubar","unified-extensions-area"],"currentVersion":21,"newElementCount":6}'';
        "browser.uiCustomization.navBarWhenVerticalTabs" = ''["sidebar-button","customizableui-special-spring4","back-button","forward-button","urlbar-container","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","unified-extensions-button","vertical-spacer"]'';
      };
      containersForce = true;
      containers = {
        "school" = {
          color = "orange";
          icon = "briefcase";
          id = 3;
        };
        "personal" = {
          color = "blue";
          icon = "fingerprint";
          id = 2;
        };
        "default" = {
          color = "red";
          icon = "circle";
          id = 1;
        };
      };
    };
  };
}
