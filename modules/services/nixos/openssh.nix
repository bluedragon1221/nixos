{
  config,
  lib,
  pkgs,
  hosts,
  ...
}: let
  cfg = config.collinux.services.sshd;
in {
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optional cfg.public cfg.port;

    services.openssh = {
      enable = true;
      allowSFTP = true;

      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      listenAddresses = [
        {
          addr =
            if cfg.public
            then "0.0.0.0"
            else "127.0.0.1";
          port = cfg.port;
        }
      ];

      # Lock down everything by default
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowAgentForwarding = false;
      };

      extraConfig = lib.concatStringsSep "\n" [
        "Match LocalPort ${toString cfg.port}"
        (
          if cfg.conf.otp
          then ''
            ChallengeResponseAuthentication yes
            PubkeyAuthentication yes
            KbdInteractiveAuthentication yes
            AuthenticationMethods publickey,keyboard-interactive:pam
          ''
          else ''
            PubkeyAuthentication yes
            AuthenticationMethods publickey
          ''
        )
        (lib.optionalString cfg.conf.rootLogin "PermitRootLogin yes")
      ];
    };

    security.pam.services = lib.optionalAttrs cfg.conf.otp {
      login.googleAuthenticator.enable = true;

      sshd.text = ''
        account required pam_unix.so

        auth required ${pkgs.google-authenticator}/lib/security/pam_google_authenticator.so nullok no_increment_hotp
        auth sufficient pam_permit.so

        session required pam_env.so conffile=/etc/pam/environment readenv=0
        session required pam_unix.so
        session required pam_loginuid.so
        session optional ${pkgs.systemd}/lib/security/pam_systemd.so
      '';
    };

    users.users = let
      k.openssh.authorizedKeys.keys =
        hosts
        |> builtins.mapAttrs (_: data: data.user_pubkey or null)
        |> builtins.attrValues
        |> builtins.filter (x: x != null);
    in {
      ${config.collinux.user.name} = k;
      "root" = lib.mkIf cfg.conf.rootLogin k;
    };

    systemd.services."openssh" = {
      after = lib.mkAfter ["network-online.target"];
      wants = lib.mkAfter ["network-online.target"];
    };
  };
}
