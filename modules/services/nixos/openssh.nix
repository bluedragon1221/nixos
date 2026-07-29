{
  config,
  lib,
  hosts,
  ...
}: let
  cfg = config.collinux.services.sshd;
  pure = x: [x];

  authorizedKeys =
    hosts
    |> builtins.mapAttrs (_: data: data.user_pubkey or null)
    |> builtins.attrValues
    |> builtins.filter (x: x != null);
in {
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      allowSFTP = true;

      hostKeys = pure {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      };

      listenAddresses = pure {
        addr = "0.0.0.0";
        port = cfg.port;
      };

      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
      };
    };

    users.users = {
      ${config.collinux.user.name}.openssh.authorizedKeys.keys = authorizedKeys;
      root.openssh.authorizedKeys.keys = authorizedKeys;
    };

    systemd.services.openssh = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
  };
}
