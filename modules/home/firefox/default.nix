{lib, ...}: let
  inherit (lib) mkOption types;
in {
  imports = [
    ./package.nix
    ./profile.nix
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

  config = {programs.firefox.enable = true;};
}
