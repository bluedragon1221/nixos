{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.services.btopweb;

  modularService = {
    lib,
    config,
    options,
    ...
  }: let
    cfg = config.btopweb;
  in {
    options.btopweb = {
      ttydPackage = lib.mkOption {
        description = "the `ttyd` package";
        type = lib.types.package;
      };
      btopPackage = lib.mkOption {
        description = "the `btop` package";
        type = lib.types.package;
      };
      btopSettings = lib.mkOption {
        description = "configuration file for btop";
        type = lib.types.lines;
      };
    };

    config =
      {
        configData."btop.conf".text = cfg.btopSettings;
        process.argv = [
          (lib.getExe cfg.ttydPackage)
          "-W"
          "-i"
          "/run/btopweb/ttyd.sock"
          "-t"
          "renderType=canvas"
          "-t"
          "fontSize=16"
          (lib.getExe cfg.btopPackage)
          "-c"
          config.configData."btop.conf".path
        ];
      }
      // lib.optionalAttrs (options ? systemd) {
        systemd.service = {
          description = "Host btop on a website";
          wants = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            DynamicUser = true;
            Group = "caddy";

            RuntimeDirectory = "btopweb";
            RuntimeDirectoryMode = "0750";
            UMask = "0002";

            # allow btop to monitor system stats
            ProtectProc = "default";
            ProcSubset = "all";

            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;

            Restart = "on-failure";
          };
        };
      };
  };
in {
  config = lib.mkIf cfg.enable {
    system.services."btopweb" = {
      imports = [modularService];
      btopweb = {
        ttydPackage = pkgs.ttyd;
        btopPackage = pkgs.btop;
        btopSettings = ''
          color_theme = "tomorrow-night"
          enable_mouse = true
          background_update = false

          proc_tree = true
          proc_colors = true
        '';
      };
    };

    services.caddy.virtualHosts."btop.ganymede".extraConfig = ''
      tls internal
      reverse_proxy unix//run/btopweb/ttyd.sock
    '';

    collinux.services.glance.homelabServices."btop" = {
      url = "https://btop.ganymede";
      icon = "si:htop";
    };
  };
}
