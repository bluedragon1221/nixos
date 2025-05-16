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

    environment.systemPackages = [pkgs.blueman];
  }
