{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.glance;
  inherit (config.systemd.lib) escapeSystemdExecArgs;
in {
  imports = [
    ./caddy-sidecar.nix
    ./crater-sidecar.nix
    ./socket-proxyd-sidecar.nix
  ];

  options.glance = {
    package = lib.mkOption {
      type = lib.types.package;
    };
    settings = lib.mkOption {
      description = "glance configuration file contents";
      type = lib.types.attrs;
    };
  };

  config = {
    crater = {
      start_address = "10.200.0.0";
      masquerade = true;
    };
    socket-proxyd.port = 8080;

    configData."config.yml".text = builtins.toJSON (
      {
        server = {
          port = 8080;
          proxied = true;
          host = "127.0.0.1";
          assets-path = "/var/lib/glance";
        };
      }
      // cfg.settings
    );

    systemd.service = {
      wants = ["network-online.service"];
      after = ["network-online.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = escapeSystemdExecArgs [
          (lib.getExe pkgs.glance)
          "-config"
          config.configData."config.yml".path
        ];
        StateDirectory = "glance";

        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
      };
    };
  };
}
