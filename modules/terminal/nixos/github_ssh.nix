{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.git;
in
  lib.mkIf cfg.installKey {
    collinux.secrets = {
      "github-ssh-key" = {
        file = ./github-ssh-key.age;
        owner = config.collinux.user.name;
      };
    };

    hjem.users.${config.collinux.user.name}.files.".ssh/id_ed25519_github.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3SjzIs3YI8PWJaNrAuaEeRcTcvIVHOKyCh2VwHTHEF 96917990+bluedragon1221@users.noreply.github.com
    '';

    programs.ssh = {
      knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      startAgent = true;

      extraConfig = ''
        Host github.com
          User git
          IdentityFile ${config.collinux.secrets."github-ssh-key".path}
          IdentitiesOnly yes
          AddKeysToAgent yes
      '';
    };
  }
