{
  config,
  lib,
  hosts,
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

      knownHosts = builtins.mapAttrs (_: data: {publicKey = data.host_pubkey;}) hosts;
    };

    users.users.${config.collinux.user.name}.openssh.authorizedKeys.keys =
      hosts
      |> (builtins.mapAttrs (_: data: data.user_pubkey or null))
      |> builtins.attrValues
      |> (builtins.filter (x: x != null));

    users.users."root".openssh.authorizedKeys.keys =
      if config.services.openssh.settings.PermitRootLogin == "prohibit-password"
      then
        hosts
        |> (builtins.mapAttrs (_: data: data.user_pubkey or null))
        |> builtins.attrValues
        |> (builtins.filter (x: x != null))
      else {};

    systemd.services."openssh" = lib.mkIf config.collinux.services.networking.networkd.enable {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];
    };

    services.tailscale.extraSetFlags = lib.optional config.services.tailscale.enable "--ssh=true";
  };
}
