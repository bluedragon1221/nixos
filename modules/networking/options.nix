{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options = {
    collinux.networking = {
      enable = mkEnableOption "wifi";
      wifiDaemon = mkOption {
        type = types.enum ["networkmanager" "iwd"];
      };
    };
  };
}
