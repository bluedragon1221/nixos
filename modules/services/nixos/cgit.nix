{
  pkgs,
  config,
  lib,
  hosts,
  ...
}: let
  cfg = config.collinux.services.cgit;

  authorizedKeys =
    hosts
    |> builtins.mapAttrs (_: data: ''command="git-shell -c \"$SSH_ORIGINAL_COMMAND\"" ${data.user_pubkey or null}'')
    |> builtins.attrValues
    |> builtins.filter (x: x != null);
in {
  config = lib.mkIf cfg.enable {
    users.groups."git" = {};
    users.users."git" = {
      isSystemUser = true;
      group = "git";
      home = "/var/lib/cgit";
      homeMode = 755;
      shell = "${pkgs.git}/libexec/git-core/git-shell";

      openssh.authorizedKeys.keys = authorizedKeys;
    };

    services.openssh.extraConfig = lib.mkAfter ''
      Match User git
        AllowTcpForwarding no
        X11Forwarding no
        PermitTunnel no
        ForceCommand git-shell
        PubkeyAuthentication yes
        AuthenticationMethods publickey
    '';

    environment.etc."cgitrc" = ''
      scan-path=/var/lib/cgit
      virtual-root=/
      repo.sort=age

      readme=:README.md
    '';

    services.fcgiwrap.instance."cgit" = {
      enable = true;

      process = {
        user = "git";
        group = "git";
      };

      socket = {
        user = "caddy";
        group = "caddy";
        type = "unix";
        address = "/run/fcgiwrap-cgit.sock";
      };
    };

    services.caddy.virtualHosts."git.ganymede".extraConfig = ''
      tls internal

      @assets path /cgit.css /cgit.js /cgit.png /favicon.ico /robots.txt
      handle @assets {
      	root * ${pkgs.cgit}/cgit
      	file_server
      }

      reverse_proxy unix//run/fcgiwrap-cgit.sock {
      	transport fastcgi {
      		env SCRIPT_FILENAME ${pkgs.cgit}/cgit/cgit.cgi
      	}
      }
    '';
  };
}
