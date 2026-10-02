{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.cgit;

  custom_cgit = pkgs.stdenv.mkDerivation {
    name = "custom-cgit-assets";
    src = pkgs.cgit;
    installPhase = ''
      mkdir -p $out
      cp -pPR ./cgit/* $out/

      rm -f $out/cgit.png $out/favicon.ico $out/cgit.css
      cp -f ${./cgit.css} $out/cgit.css
    '';
  };

  md2html = pkgs.writeShellScriptBin "md2html.sh" ''
    #!/bin/sh
    echo '<div class="markdown-body">'
    ${lib.getExe pkgs.cmark-gfm} \
      --extension table \
      --extension tasklist \
      --extension strikethrough \
      --extension autolink
    echo '</div>'
  '';
in {
  imports = [./gitShellCommands.nix];

  config = lib.mkIf cfg.enable {
    users.groups."git" = {};
    users.users."git" = {
      isSystemUser = true;
      group = "git";
      shell = "${pkgs.git}/bin/git-shell";

      home = "/var/lib/cgit";
      createHome = true;
      homeMode = "755";

      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3SjzIs3YI8PWJaNrAuaEeRcTcvIVHOKyCh2VwHTHEF"];
    };

    services.openssh.extraConfig = lib.mkAfter ''
      Match User git
        AllowTcpForwarding no
        X11Forwarding no
        PermitTunnel no
        PubkeyAuthentication yes
        AuthenticationMethods publickey
    '';

    environment.etc."cgitrc".text = ''
      repo.sort=age
      enable-http-clone=1
      enable-commit-graph=1

      root-title=Repositories
      root-desc=Git repos for my various personal projects

      readme=:README.md
      about-filter=${lib.getExe md2html}
      source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py
      head-include=${./cgit-head.html}
      footer=

      virtual-root=/
      scan-path=/var/lib/cgit
    '';

    systemd.sockets."fcgiwrap-cgit" = {
      wantedBy = ["sockets.target"];
      listenStreams = ["/run/cgit/fcgiwrap.sock"];
      socketConfig = {
        SocketMode = "0660";
        SocketGroup = "caddy";
      };
    };

    systemd.services."fcgiwrap-cgit" = {
      after = ["nss-user-lookup.target"];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.fcgiwrap} -c 1";
        User = "git";
        Group = "git";
      };
    };

    services.caddy.virtualHosts."git.collin.williamsfam.us.com".extraConfig = ''
      @assets path /cgit.css /cgit.js /favicon.svg /robots.txt
      handle @assets {
          root * ${custom_cgit}
          file_server
      }

      reverse_proxy unix//run/cgit/fcgiwrap.sock {
          transport fastcgi {
              env SCRIPT_FILENAME ${custom_cgit}/cgit.cgi
          }
      }
    '';

    collinux.services.glance.homelabServices."git" = {
      url = "https://git.collin.williamsfam.us.com";
      icon = "si:git";
    };
  };
}
