{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux.user = {
      name = mkOption {
        type = types.str;
      };
      password = mkOption {
        type = types.str;
        description = "hashed password for user";
      };
      isAdmin = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };
}
