{config, ...}: let
  cfg = config.collinux.firefox;
in {
  programs.firefox.profiles."${cfg.profileName}" = {
    isDefault = true;
    search.default = "ddg";

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

    settings = {
      "browser.aboutConfig.showWarning" = false;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.urlbar.groupLabels.enabled" = false;
    };
  };
}
