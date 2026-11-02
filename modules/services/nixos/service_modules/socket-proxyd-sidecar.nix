{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  inherit (config._module.args) name;
  inherit (config.systemd.lib) escapeSystemdExecArgs;

  cfg = config.socket-proxyd;
in {
  options.socket-proxyd = {
    port = lib.mkOption {
      type = lib.types.port;
    };
    sock = lib.mkOption {
      type = lib.types.str;
      default = "/run/${name}/${name}.sock";
    };
  };

  config = lib.mkMerge [
    {
      systemd.sockets."proxy" = {
        wantedBy = ["sockets.target"];
        listenStreams = [cfg.sock];
        socketConfig = {
          SocketMode = "0660";
          SocketGroup = "caddy";
        };
      };
      systemd.services."proxy" = {
        requires = ["${name}.service"];
        after = ["${name}.service"];

        serviceConfig = {
          ExecStart = escapeSystemdExecArgs [
            "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd"
            "127.0.0.1:${toString cfg.port}"
          ];

          DynamicUser = true;
          PrivateTmp = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };
    }
    (lib.optionalAttrs (options ? caddy) {
      caddy.reverseProxy = "unix/${cfg.sock}";
    })
  ];
}
