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

  hjem.clobberByDefault = true;
  hjem.users."${cfg.name}" = {
    enable = true;
    directory = "/home/${cfg.name}";
    user = cfg.name;
  };

  security.sudo-rs.enable = true;
}
