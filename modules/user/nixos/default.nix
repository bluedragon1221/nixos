{config, ...}: let
  cfg = config.collinux.user;
in {
  users.users."${cfg.name}" = {
    isNormalUser = true;
    description = cfg.name;
    # group = cfg.name;
    extraGroups =
      ["networkmanager" "disks"]
      ++ (
        if cfg.isAdmin
        then ["wheel"]
        else []
      );
    hashedPassword = cfg.password;
  };
  # users.groups."${cfg.name}" = {};
}
