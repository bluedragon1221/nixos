{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options = {
    collinux.user = {
      name = mkOption {
        description = "Name for the sole user of this system";
        type = types.str;
        default = "collin";
      };
      isAdmin = mkOption {
        description = "Whether this user is an admin";
        type = types.bool;
        default = true;
      };

      useRun0 = mkEnableOption "whether to use systemd's run0 instead of sudo-rs";
    };
  };
}
