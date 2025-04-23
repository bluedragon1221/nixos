{
  programs.firefox = {
    enable = true;
    policies = {
      DisablePocket = true;
      DisableAccounts = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableFeedbackCommands = true;
      DontCheckDefaultBrowser = true;
      NetworkPrediction = true; # this should make it faster?
      HttpsOnlyMode = "force_enabled";
      DNSOverHttps = {
        Enabled = true;
        Locked = true;
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        Locked = true;
      };
      StartDownloadsInTempDirectory = true;
      SanitizeOnShutdown = false;

      # Cleaner New Tab page
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };

      # Disable Builtin Password Manager
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;

      # Allow Popups for specific sites
      PopupBlocking.Allow = ["https://classroom.google.com"];

      # Bookmarks
      DisplayBookmarksToolbar = "always";
      NoDefaultBookmarks = true;

      Preferences = let
        val = Value: {
          inherit Value;
          Status = "locked";
        };
      in {
        "extensions.activeThemeID" = val "catppuccin-mocha-blue@mozilla.org"; # theme
        "browser.aboutConfig.showWarning" = val false; # I sometimes know what I'm doing
        "browser.download.useDownloadDir" = val false; # Ask where to save stuff
        "browser.tabs.tabmanager.enabled" = val false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = val true;
        "svg.context-properties.content.enabled" = val true;
        "browser.compactmode.show" = val true;
        "browser.uidensity" = val 1;
      };

      ExtensionSettings = let
        ext = url: {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${url}/latest.xpi";
        };
      in {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = ext "bitwarden-password-manager";
        "{88b098c8-19be-421e-8ffa-85ddd1f3f004}" = ext "catppuccin-mocha-blue";
        "simple-tab-groups@drive4ik" = ext "simple-tab-groups";
        "uBlock0@raymondhill.net" = ext "ublock-origin";
      };
    };
  };
}
