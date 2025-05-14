{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux = {
      theme = mkOption {
        type = types.enum ["catppuccin" "adwaita"];
      };

      facter = mkOption {
        type = types.bool;
        description = "whether or not this system is using facter";
      };
      disko = mkOption {
        type = types.bool;
        description = "whether or not this system is using disko";
      };

      extraHomeModules = mkOption {
        type = types.listOf types.path;
        default = [];
      };

      extraSystemModules = mkOption {
        type = types.listOf types.path;
        default = [];
      };
    };
  };
}
