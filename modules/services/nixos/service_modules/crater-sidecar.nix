{
  lib,
  config,
  pkgs,
  options,
  ...
}: let
  inherit (config._module.args) name;
  inherit (config.systemd.lib) escapeSystemdExecArgs;

  crater_pkg = pkgs.callPackage ../../../../pkgs/crater {};

  cfg = config.crater;
in {
  options.crater = {
    masquerade = lib.mkOption {
      description = "should this service be able to reach the internet, masquerading as the host?";
      type = lib.types.bool;
    };
    start_address = lib.mkOption {
      description = "isolated service that the service runs inside";
      type = lib.types.str;
    };
    netns = lib.mkOption {
      description = "autofilled path to the netns created by crater";
      type = lib.types.str;
    };
  };

  config = let
    o = builtins.elemAt <| lib.strings.splitString "." cfg.start_address;
    hostAddr = "${o 0}.${o 1}.${o 2}.${toString ((lib.toIntBase10 (o 3)) + 1)}";
  in
    lib.mkMerge [
      {
        crater.netns = "/run/crater/${name}";

        systemd.service = {
          requires = ["${name}-crater.service"];
          after = ["${name}-crater.service"];

          serviceConfig = {
            NetworkNamespacePath = cfg.netns;
            BindReadOnlyPaths = ["${builtins.toFile "${name}-resolv.conf" "namespace ${hostAddr}"}"];
          };
        };

        systemd.services."crater" = {
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = escapeSystemdExecArgs [
              (lib.getExe crater_pkg)
              "up"
              "--name=${name}"
              "--subnet=${cfg.start_address}/30"
              "--masquerade=${
                if cfg.masquerade
                then "yes"
                else "no"
              }"
            ];
            ExecStop = escapeSystemdExecArgs [
              (lib.getExe crater_pkg)
              "down"
              "--name=${name}"
            ];
          };
        };
      }
      (lib.optionalAttrs (options ? socket-proxyd) {
        systemd.services."proxy" = {
          requires = ["${name}-crater.service"];
          after = ["${name}-crater.service"];
          serviceConfig.NetworkNamespacePath = cfg.netns;
        };
      })
    ];
}
