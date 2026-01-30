{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.system.bluetooth;
in
  lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings.General = {
        ControllerMode = "bredr";
        FastConnectable = true;
        JustWorksRepairing = "always";
      };
    };

    systemd.user.services."mpris-proxy" = {
      unitConfig = {
        BindsTo = ["bluetooth.target"];
        After = ["bluetooth.target"];
      };

      wantedBy = ["bluetooth.target"];

      # serviceConfig already exists (?)
    };

    # hardening (down to 2.1 OK)
    systemd.services."bluetooth".serviceConfig = {
      IPAddressDeny = "any";
      ProtectKernelLogs = true;
      ProtectKernelModules = lib.mkForce true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_BLUETOOTH"];
      ProtectClock = true;
      ProcSubset = "pid";
    };
  }
