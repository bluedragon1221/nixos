{
  config,
  lib,
  pkgs,
  hosts,
  ...
}: let
  cfg = config.collinux.services.networking.sshd;
in {
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [2222]; # only on local network

    services.openssh = {
      enable = true;

      allowSFTP = false;

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
        {
          addr = cfg.bind_host;
          port = 2222;
        }
      ];

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
        KbdInteractiveAuthentication = true; # for google authenticator totp codes
        AuthenticationMethods = "publickey,keyboard-interactive:pam";
      };

      extraConfig = ''
        Match LocalPort 2222
          AuthenticationMethods publickey
          PermitRootLogin prohibit-password
      '';
    };

    security.pam.services = {
      login.googleAuthenticator.enable = true;

      sshd.text = ''
        account required pam_unix.so # unix (order 10900)

        auth required ${pkgs.google-authenticator}/lib/security/pam_google_authenticator.so nullok no_increment_hotp # google_authenticator (order 12500)
        auth sufficient pam_permit.so

        session required pam_env.so conffile=/etc/pam/environment readenv=0 # env (order 10100)
        session required pam_unix.so # unix (order 10200)
        session required pam_loginuid.so # loginuid (order 10300)
        session optional ${pkgs.systemd}/lib/security/pam_systemd.so # systemd (order 12000)
      '';
    };

    users.users.${config.collinux.user.name}.openssh.authorizedKeys.keys =
      hosts
      |> (builtins.mapAttrs (_: data: data.user_pubkey or null))
      |> builtins.attrValues
      |> (builtins.filter (x: x != null));

    users.users."root".openssh.authorizedKeys.keys =
      hosts
      |> (builtins.mapAttrs (_: data: data.user_pubkey or null))
      |> builtins.attrValues
      |> (builtins.filter (x: x != null)); # only possible over home network (:2222)

    systemd.services."openssh" = lib.mkIf config.collinux.services.networking.networkd.enable {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];
    };

    services.tailscale.extraSetFlags = lib.optional config.services.tailscale.enable "--ssh=true";
  };
}
