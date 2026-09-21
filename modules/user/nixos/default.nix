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
      extraGroups = ["networkmanager" "disks" "input" "video" "dialout" "kvm"] ++ (lib.optional cfg.isAdmin "wheel");
    };
  };
  services.userborn.enable = true;

  # sudo
  security = {
    sudo.enable = false;
    sudo-rs = lib.mkIf (!cfg.useRun0) {
      enable = true;
      extraConfig = ''
        Defaults pwfeedback
      '';
    };
    run0 = {
      enable = cfg.useRun0;
      enableSudoAlias = cfg.useRun0;
    };
  };

  time.timeZone = "America/Chicago";

  programs.ssh = {
    systemd-ssh-proxy.enable = false;

    knownHosts =
      hosts
      |> lib.filterAttrs (_: data: data ? host_pubkey)
      |> builtins.mapAttrs (_: data:
        {
          publicKey = data.host_pubkey;
        }
        // (lib.optionalAttrs (data ? hostnames) {
          hostNames =
            data.hostnames
            ++ (
              if data ? ip
              then [data.ip]
              else []
            );
        }));
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
