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
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };

    services.tailscale.extraSetFlags = lib.optional config.services.tailscale.enable "--ssh=true";
  };
}
