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
      openFirewall = false;
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
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };

    systemd.services."openssh" = lib.mkIf config.collinux.services.networking.networkd.enable {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];
    };

    services.tailscale.extraSetFlags = lib.optional config.services.tailscale.enable "--ssh=true";
  };
}
