{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.caddy;
in {
  options.caddy = {
    virtualHost = lib.mkOption {
      description = "host for caddy";
      example = "app.ganymede";
      type = lib.types.str;
    };
    reverseProxy = lib.mkOption {
      description = "target for caddy to reverse proxy";
      example = "unix//run/app/app.sock";
      type = lib.types.str;
    };
    internal = lib.mkOption {
      description = "whether this service is publically accessable or not";
      type = lib.types.bool;
    };
  };

  config = let
    routeId = "route-${cfg.virtualHost}";
    tlsId = "tls-${cfg.virtualHost}";
  in {
    configData = {
      "route.json".text = builtins.toJSON {
        "@id" = routeId;
        match = [{host = [cfg.virtualHost];}];
        terminal = true;
        handle = [
          {
            handler = "subroute";
            routes =
              lib.optional cfg.internal {
                match = [{not = [{remote_ip.ranges = ["10.100.0.0/24" "192.168.50.0/24" "10.200.0.0/30"];}];}];
                handle = [
                  {
                    handler = "static_response";
                    abort = true;
                  }
                ];
              }
              ++ [
                {
                  handle = [
                    {
                      handler = "reverse_proxy";
                      upstreams = [{dial = cfg.reverseProxy;}];
                    }
                  ];
                }
              ];
          }
        ];
      };
      "tls.json".text = builtins.toJSON {
        "@id" = tlsId;
        subjects = [cfg.virtualHost];
        issuers = [{module = "internal";}];
      };
    };
    systemd.services."caddy-sidecar" = let
      curl = "${lib.getExe pkgs.curl} --silent --show-error --unix-socket /run/caddy/caddy-admin.sock";
    in {
      after = ["caddy.service"];
      requires = ["caddy.service"];
      partOf = ["caddy.service"]; # re-run when caddy restarts
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        DynamicUser = true;
        Group = "caddy";

        ExecStart =
          ["-${curl} -X DELETE http://localhost/id/${routeId}"]
          ++ lib.optionals cfg.internal [
            "-${curl} -X DELETE http://localhost/id/${tlsId}"
            "${curl} --fail --retry 10 --retry-all-errors --retry-delay 1 -X PUT -H 'Content-Type: application/json' --data-binary @${config.configData."tls.json".path} http://localhost/config/apps/tls/automation/policies/0"
          ]
          ++ ["${curl} --fail -X POST -H 'Content-Type: application/json' --data-binary @${config.configData."route.json".path} http://localhost/config/apps/http/servers/main/routes"];
        ExecStop =
          ["-${curl} -X DELETE http://localhost/id/${routeId}"]
          ++ lib.optional cfg.internal "-${curl} -X DELETE http://localhost/id/${tlsId}";

        PrivateNetwork = true;
        RestrictAddressFamilies = ["AF_UNIX"];
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };
  };
}
