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
    ./theme_adwaita.nix
    ./theme_catppuccin.nix
  ];

  options = {
    collinux.firefox = {
      profileName = mkOption {
        type = types.str;
      };
      theme = mkOption {
        type = types.enum ["none" "catppuccin" "adwaita"];
        default = "none";
      };
    };
  };

  config = {
    programs.firefox.enable = true;
  };
}
