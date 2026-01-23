{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.user;
in {
  users = {
    mutableUsers = true; # system passwords stored mutably

    users."${cfg.name}" = {
      isNormalUser = true;
      description = cfg.name;
      extraGroups = ["networkmanager" "pipewire" "disks" "input" "video" "dialout" "kvm"] ++ (lib.optional cfg.isAdmin "wheel");
    };
  };
  services.userborn.enable = true;

  # sudo
  security = {
    sudo.enable = false;
    sudo-rs.enable = false;

    run0.enableSudoAlias = true;
  };

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
