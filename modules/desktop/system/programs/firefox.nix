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

        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";

        ExtensionSettings = let
          ext = name: {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
          };
        in
          lib.mkMerge [
            {
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = ext "bitwarden-password-manager";
              "uBlock0@raymondhill.net" = ext "uBlock0@raymondhill.net";
              "addon@darkreader.org" = ext "addon@darkreader.org";
            }
            (lib.optionalAttrs (cfg.theme == "catppuccin") {
              "{88b098c8-19be-421e-8ffa-85ddd1f3f004}" = ext "catppuccin-mocha-blue";
            })
          ];
      };
    };

    hjem.users."${config.collinux.user.name}".files = {
      ".mozilla/firefox/profiles.ini".text = ''
        [Profile0]
        Name=collin
        IsRelative=1
        Path=collin
        Default=1

        [General]
        StartWithLastProfile=1
        Version=2
      '';
    };
  }
