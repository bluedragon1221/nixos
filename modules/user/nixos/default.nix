{
  config,
  lib,
  hosts,
  ...
}: let
  cfg = config.collinux.user;
in {
  users = {
    mutableUsers = true; # system passwords stored mutably

    users.${cfg.name} = {
      isNormalUser = true;
      description = cfg.name;
      extraGroups = ["networkmanager" "pipewire" "disks" "input" "video" "dialout" "kvm"] ++ (lib.optional cfg.isAdmin "wheel");
    };
  };
  services.userborn.enable = true;

  # sudo
  security = {
    sudo.enable = false;
    sudo-rs.enable = !cfg.useRun0;
    run0.enableSudoAlias = cfg.useRun0;
  };

  time.timeZone = "America/Chicago";

  programs.ssh = {
    systemd-ssh-proxy.enable = false;

    knownHosts = builtins.mapAttrs (_: data: {publicKey = data.host_pubkey;}) hosts;

    extraConfig = ''
      StrictHostKeyChecking accept-new
    '';
  };

  hjem = {
    clobberByDefault = true;
    users."${cfg.name}" = {
      enable = true;
      directory = "/home/${cfg.name}";
      user = cfg.name;
    };
  };
}
