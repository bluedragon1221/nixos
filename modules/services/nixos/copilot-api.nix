{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.services.copilot-api;
in {
  config = lib.mkIf cfg.enable {
    users.groups."copilot-api" = {};
    users.users."copilot-api" = {
      isSystemUser = true;
      group = "copilot-api";
      home = "/var/lib/copilot-api";
      createHome = true;
    };

    systemd.services."copilot-api" = {
      description = "GitHub Copilot API Proxy";
      restartIfChanged = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "copilot-api";
        Group = "copilot-api";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";

        # Load environment variables from file (e.g., GH_TOKEN)
        EnvironmentFile = lib.mkIf (cfg.githubToken != null) cfg.githubToken;

        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;

        # Allow writing to state directory
        StateDirectory = "copilot-api";
        WorkingDirectory = "/var/lib/copilot-api";

        ExecStart = let
          copilot-api = pkgs.callPackage ../../../pkgs/copilot-api {};
          # Use bash to read token from environment and pass to command
          startScript = pkgs.writeShellScript "copilot-api-start" ''
            exec ${copilot-api}/bin/copilot-api start \
              --port ${toString cfg.port} \
              --host ${cfg.listenAddr} \
              ${lib.optionalString (cfg.githubToken != null) "--github-token \"$GH_TOKEN\""}
          '';
        in "${startScript}";
      };
    };
  };
}
