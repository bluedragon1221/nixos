{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.git;
in
  lib.mkIf cfg.installKey {
    # public key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3SjzIs3YI8PWJaNrAuaEeRcTcvIVHOKyCh2VwHTHEF"
    collinux.secrets = {
      "github-ssh-key" = {
        file = ./github-ssh-key.age;
        owner = config.collinux.user.name;
      };
    };

    programs.ssh = {
      knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      startAgent = true;

      extraConfig = ''
        Host github.com
          User git
          IdentityFile ${config.collinux.secrets."github-ssh-key".path}
          IdentitiesOnly yes
          AddKeysToAgent yes

        Match host williamsfam.us.com user forgejo
          IdentityFile ${config.collinux.secrets."github-ssh-key".path}
          IdentitiesOnly yes
          AddKeysToAgent yes
      '';
    };
  }
