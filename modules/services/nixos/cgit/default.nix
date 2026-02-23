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
      cp -f ${./favicon.svg} $out/favicon.svg
      cp -f ${./cgit.css} $out/cgit.css
    '';
  };
in {
  imports = [
    (import ../mkCaddyCfg.nix cfg)
    ./gitShellCommands.nix
  ];

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
      logo=/favicon.svg
      favicon=/favicon.svg

      repo.sort=age
      enable-http-clone=1
      enable-commit-graph=1
      side-by-side-diffs=1

      root-title=git@ganymede
      root-desc=Git repos associated with Ganymede

      readme=:README.md
      about-filter=${custom_cgit}/lib/cgit/filters/html-converters/md2html
      source-filter=${custom_cgit}/lib/cgit/filters/syntax-highlighting.py
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

    collinux.services.cgit.manualCaddyConfig = ''
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
  };
}
