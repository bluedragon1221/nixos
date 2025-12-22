{
  config,
  hostname,
  lib,
  ...
}: let
  cfg = config.collinux.user;
in {
  users = {
    mutableUsers = true;

    users."${cfg.name}" = {
      isNormalUser = true;
      description = cfg.name;
      extraGroups = ["networkmanager" "pipewire" "disks" "input" "video" "dialout" "kvm"] ++ (lib.optional cfg.isAdmin "wheel");
    };
  };
  security.sudo-rs.enable = true;
  services.userborn.enable = true;

  time.timeZone = "America/Chicago";

  hjem = {
    clobberByDefault = true;
    users."${cfg.name}" = {
      enable = true;
      directory = "/home/${cfg.name}";
      user = cfg.name;
    };
  };
}
