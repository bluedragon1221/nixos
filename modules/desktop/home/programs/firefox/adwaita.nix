{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;

  firefox-gnome-theme = builtins.fetchGit {
    url = "https://github.com/rafaelmardojai/firefox-gnome-theme";
    rev = "59e3de00f01e5adb851d824cf7911bd90c31083a";
  };
in
  lib.mkIf (cfg.enable && cfg.theme == "adwaita") {
    home.file.".mozilla/firefox/${cfg.profileName}/chrome" = {
      recursive = true;
      source = firefox-gnome-theme;
    };

    programs.firefox.profiles."${cfg.profileName}" = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
      };
    };
  }
