{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  imports = [
    ./package.nix
    ./profile.nix
    ./theme_gtk.nix
    ./theme_catppuccin.nix
  ];

  options = {
    collinux.firefox = {
      profileName = mkOption {
        type = types.str;
      };
      theme = mkOption {
        type = types.enum ["none" "catppuccin" "gtk"];
        default = "none";
      };
    };
  };

  config = let
    cfg = config.collinux.firefox;
  in {
    programs.firefox.enable = true;

    # keeps getting backup errors for some reason
    home.file.".mozilla/${cfg.profileName}/search.json.mozlz4".force = true;
  };
}
