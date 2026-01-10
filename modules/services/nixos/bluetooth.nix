{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.bluetooth;
in
  lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # hardening (down to 2.1 OK)
    systemd.services."bluetooth".serviceConfig = {
      IPAddressDeny = "any";
      ProtectHostname = true;
      ProtectKernelTunables = lib.mkForce true;
      ProtectKernelLogs = true;
      ProtectKernelModules = lib.mkForce true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_BLUETOOTH"];
      ProtectClock = true;
      ProcSubset = "pid";
    };

    environment.systemPackages = [
      (lib.mkIf cfg.blueman.enable pkgs.blueman)
      (lib.mkIf cfg.bluetuith.enable pkgs.bluetuith)
    ];
  }
