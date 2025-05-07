{config, ...}: let
  cfg = config.collinux.user;
in {
  users.users."${cfg.name}" = {
    isNormalUser = true;
    description = cfg.name;
    extraGroups =
      ["networkmanager" "disks"]
      ++ (
        if cfg.isAdmin
        then ["wheel"]
        else []
      );
    hashedPassword = cfg.password;
  };

  security.sudo-rs.enable = true;
}
