{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.cgit;
in {
  config = lib.mkIf cfg.enable {
    environment.shells = ["${pkgs.git}/bin/git-shell"];
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
    hjem.users."git".files = {
      "git-shell-commands/set-description" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          repo="$1"
          desc="$2"
          base="/var/lib/cgit"
          repo_path="$base/$repo"

          test -d "$repo_path" || { echo "Repository does not exist"; exit 1; }

          # Prevent path traversal
          real=$(realpath "$repo_path")
          if [[ "$real" != "$base/"* ]]; then
              echo "Invalid path"
              exit 1
          fi

          echo "$desc" | head -n 1 > "$repo_path/description"

          echo "Description updated for '$repo'"
        '';
      };
      "git-shell-commands/create-repo" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          repo="$1"
          base="/var/lib/cgit"
          repo_path="$base/$repo"

          test -d "$repo_path" && { echo "Repository already exists."; exit 1; }

          git init --bare "$repo_path"
          echo "Repository '$repo' created"
        '';
      };
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
      diff-style=ssdiff

      root-title=Ganymede Public Git Server
      root-desc=

      readme=:README.md
      about-filter=${pkgs.cgit}/lib/cgit/filters/html-converters/md2html

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

    networking.extraHosts = "127.0.0.1 git.ganymede";
    services.caddy.virtualHosts."git.ganymede".extraConfig = let
      custom_cgit = pkgs.stdenv.mkDerivation {
        name = "custom-cgit-assets";
        src = pkgs.cgit;
        installPhase = ''
          mkdir -p $out
          cp -pPR ./cgit/* $out/

          rm -f $out/cgit.png $out/favicon.ico
          cp -f ${../favicon.svg} $out/favicon.svg
        '';
      };
    in ''
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
  };
}
