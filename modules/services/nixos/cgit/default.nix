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
      shell = lib.getExe pkgs.git;

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

      root-title=git@ganymede
      root-desc=Git repos associated with Ganymede

      readme=:README.md
      about-filter=${md2html}/bin/md2html.sh
      source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.py
      head-include=${./cgit-head.html}
      footer=

      virtual-root=/
      scan-path=/var/lib/cgit
    '';

    services.fcgiwrap.instances."cgit" = {
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

      @assets path /cgit.css /cgit.js /favicon.svg /robots.txt
      handle @assets {
      	root * ${custom_cgit}
      	file_server
      }

      reverse_proxy unix//run/fcgiwrap-cgit.sock {
      	transport fastcgi {
      		env SCRIPT_FILENAME ${custom_cgit}/cgit.cgi
      	}
      }
    '';

    collinux.services.glance.homelabServices."git" = {
      url = "https://git.ganymede";
      icon = "si:git";
    };
  };
}
