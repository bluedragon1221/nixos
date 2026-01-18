{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux.user = {
      name = mkOption {
        description = "Name for the sole user of this system";
        type = types.str;
      };
      isAdmin = mkOption {
        description = "Whether this user is an admin";
        type = types.bool;
        default = true;
      };
    };
  };
}
