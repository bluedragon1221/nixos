{
  pkgs,
  forceXdg,
}: let
  # Preferences
  Preferences = let
    val = Value: {
      inherit Value;
      Status = "locked";
    };
  in {
    # "extensions.activeThemeID" = val "catppuccin-macchiato-blue@mozilla.org"; # theme
    "browser.aboutConfig.showWarning" = val false; # I sometimes know what I'm doing
    "browser.download.useDownloadDir" = val false; # Ask where to save stuff
    "browser.tabs.tabmanager.enabled" = val false;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = val true;
  };

  # Extensions
  ExtensionSettings = let
    ext = url: {
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${url}/latest.xpi";
    };
  in {
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = ext "bitwarden-password-manager";
    "{d49033ac-8969-488c-afb0-5cdb73957f41}" = ext "catppuccin-macchiato-blue";
    "uBlock0@raymondhill.net" = ext "ublock-origin";
  };

  # Bookmarks
  ManagedBookmarks = let
    bookmark = name: url: {inherit name url;};
    folder = name: children: {inherit name children;};
  in [
    (folder "School" [
      (bookmark "Google Classroom" "https://classroom.google.com")
      (bookmark "NetAcademy" "https://netacad.com")
    ])
    (folder "Nix" [
      (bookmark "Packages Search" "https://search.nixos.org/packages")
      (bookmark "Options Search" "https://search.nixos.org/options")
    ])
    (bookmark "Claude" "https://claude.ai")
    (bookmark "GitHub" "https://github.com")
  ];

  extraPolicies = {
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
    SanitizeOnShutdown = true; # Um...

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

    inherit ManagedBookmarks ExtensionSettings Preferences;
  };

  wrapped-firefox = pkgs.firefox.override {
    inherit extraPolicies;
    extraPrefsFiles = [
      (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
        sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
      })
    ];
  };
in
  wrapped-firefox
# forceXdg {
#   pkg = wrapped-firefox;
#   binName = "firefox";
#   preDelete = ["~/.pki" "~/.mozilla"];
# }

