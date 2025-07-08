{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options = {
    collinux.services = {
      networking = {
        enable = mkEnableOption "wifi";
        iwd.enable = mkEnableOption "lightweight wifi daemon";
        networkmanager.enable = mkEnableOption "heavier wifi daemon";
      };
      audio = {
        enable = mkEnableOption "pipewire + wireplumber";
        pulse.enable = mkEnableOption "pipewire-pulse";
        # some config to make audio work with wine (TODO for jupiter)
      };
      bluetooth = {
        enable = mkEnableOption "bluetooth";
        blueman.enable = mkEnableOption "graphical bluetooth manager";
        bluetuith.enable = mkEnableOption "terminal bluetooth manager";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = with config.collinux.services.networking; !(iwd.enable && networkmanager.enable);
        message = "can not use iwd and networkmanager at the same time";
      }
    ];
  };
}
