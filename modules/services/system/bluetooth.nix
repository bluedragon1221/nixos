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

    environment.systemPackages = [
      (lib.mkIf cfg.blueman.enable pkgs.blueman)
      (lib.mkIf cfg.bluetuith.enable pkgs.bluetuith)
    ];
  }
