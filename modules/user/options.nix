{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux.user = {
      name = mkOption {
        type = types.str;
      };
      isAdmin = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
}
