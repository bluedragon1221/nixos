{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.networking.sshd;
in {
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      listenAddresses = [
        {
          addr = cfg.bind_host;
          port = 22;
        }
      ];

      settings = {
        PermitRootLogin = "prohibit-password"; # deploy-rs uses root account
        PasswordAuthentication = false;
      };

      knownHosts = {
        "mercury".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQtMAgPdWwrOzlZT/lEIRQZ+ajhafG9AEJCrF2/bsmN";
        "jupiter".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB7feUHl5qoD5zF9AMOV2meViA+wZYdVvbVjPkggZf8";
        "ganymede".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlr+53UmlGVP1blkdNl6NFqn1w2umFJyjH1EVUPKIy9";
      };
    };

    users.users.${config.collinux.user.name}.openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvxtKW0rmRBi8J67gLrLv8Zv338AcmZ3P20DePiUfnX mercury"
      ];
    };

    systemd.services."openssh" = lib.mkIf config.collinux.services.networking.networkd.enable {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];
    };

    services.tailscale.extraSetFlags = lib.optional config.services.tailscale.enable "--ssh=true";
  };
}
