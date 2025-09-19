{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;
in
  lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        PasswordManagerEnabled = false; # use bitwarden instead
        DisableAccounts = true;
        DisablePocket = true;
        NoDefaultBookmarks = true;

        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        Homepage = "";

        NewTabPage = false;

        Preferences = let
          opt = Value: {
            inherit Value;
            Status = "locked";
          };
        in {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = opt true;
          "browser.tabs.inTitlebar" = opt 0;
          "browser.tabs.hoverPreview.enabled" = opt 0;

          "browser.tabs.loadBookmarksInTabs" = opt true;
          "browser.toolbars.bookmarks.visibility" = opt "never";
          "browser.uiCustomization.state" = opt (lib.replaceStrings ["\n" " "] ["" ""] ''
            {
              "placements": {
                "widget-overflow-fixed-list": [],
                "unified-extensions-area": [
                  "zotero_chnm_gmu_edu-browser-action",
                  "addon_darkreader_org-browser-action",
                  "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                ],
                "nav-bar": [
                  "personal-bookmarks",
                  "customizableui-special-spring1",
                  "back-button",
                  "forward-button",
                  "stop-reload-button",
                  "urlbar-container",
                  "downloads-button",
                  "unified-extensions-button",
                  "ublock0_raymondhill_net-browser-action",
                  "customizableui-special-spring2"
                ],
                "toolbar-menubar": [
                  "menubar-items"
                ],
                "TabsToolbar": [
                  "tabbrowser-tabs",
                  "new-tab-button"
                ],
                "vertical-tabs": [],
                "PersonalToolbar": []
              },
              "seen": [
                "developer-button",
                "zotero_chnm_gmu_edu-browser-action",
                "addon_darkreader_org-browser-action",
                "ublock0_raymondhill_net-browser-action",
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action",
                "screenshot-button"
              ],
              "dirtyAreaCache": [],
              "currentVersion": 23,
              "newElementCount": 2
            }
          '');

          "accessibility.force_disabled" = opt 1;
          "browser.aboutConfig.showWarning" = opt false;

          "startup.homepage_welcome_url" = opt "";
          "trailhead.firstrun.didSeeAboutWelcome" = opt true;
          "datareporting.policy.dataSubmissionPolicyBypassNotification" = opt true;
          "browser.startup.homepage" = opt "about:blank";

          "browser.compactmode.show" = opt true;
          "browser.uidensity" = opt 1;

          "media.webspeech.synth.enabled" = opt false; # im not disabled
          "media.webspeech.synth.dont_notify_on_error" = opt true;

          # get that AI out of my browser
          "browser.ml.chat.enabled" = opt false;
          "browser.ml.enable" = opt false;
        };

        ExtensionSettings = let
          ext = name: {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
          };
        in
          {
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = ext "bitwarden-password-manager";
            "uBlock0@raymondhill.net" = ext "uBlock0@raymondhill.net";
            "addon@darkreader.org" = ext "addon@darkreader.org";
          }
          // (lib.optionalAttrs (cfg.theme == "catppuccin") {
            "{88b098c8-19be-421e-8ffa-85ddd1f3f004}" = ext "catppuccin-mocha-blue";
          })
          // (lib.optionalAttrs (cfg.extensions.zotero.enable) {
            "zotero@chnm.gmu.edu" = {
              installation_mode = "force_installed";
              install_url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.181.xpi";
            };
          });
      };
    };

    services.speechd.enable = lib.mkForce false; # gets installed by firefox, but we don't need it
  }
