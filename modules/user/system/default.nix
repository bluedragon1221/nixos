{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.user;
in {
  users.users."${cfg.name}" = {
    isNormalUser = true;
    description = cfg.name;
    extraGroups = ["networkmanager" "disks" "input" "video"] ++ (lib.optional cfg.isAdmin "wheel");
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
