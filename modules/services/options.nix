{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options = {
    collinux.services = {
      networking = {
        enable = mkEnableOption "wifi";
        wifiDaemon = mkOption {
          type = types.enum ["networkmanager" "iwd"];
        };
      };
      audio = {
        enable = mkEnableOption "pipewire + wireplumber";
        pulse.enable = mkEnableOption "pipewire-pulse";
        # some config to make audio work with wine (TODO for jupiter)
      };
      bluetooth.enable = mkEnableOption "bluetooth";
    };
  };
}
