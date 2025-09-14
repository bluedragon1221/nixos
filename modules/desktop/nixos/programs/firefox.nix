{
  pkgs,
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
        DisplayBookmarksToolbar = "always";

        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";

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

          "accessibility.force_disabled" = opt 1;

          "browser.compactmode.show" = opt true;
          "browser.uidensity" = opt 1;

          "media.webspeech.synth.enabled" = opt false; # im not disabled
          "media.webspeech.synth.dont_notify_on_error" = opt true;
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
      };
    };

    services.speechd.enable = lib.mkForce false; # gets installed by firefox, but we don't need it
  }
