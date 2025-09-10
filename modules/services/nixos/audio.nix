{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.audio;
in
  lib.mkIf cfg.enable {
    security.rtkit.enable = false;
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;

      pulse.enable = cfg.pulse.enable;
    };

    environment.systemPackages = [pkgs.pwvucontrol];
  }
