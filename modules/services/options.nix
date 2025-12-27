{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption;
in {
  options = {
    collinux.services = {
      networking = {
        enable = mkEnableOption "wifi";
        iwd.enable = mkEnableOption "lightweight wifi daemon";
        networkmanager.enable = mkEnableOption "heavier wifi daemon";

        static = let
          ip_addr =
            lib.types.strMatching
            "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$";
        in {
          enable = mkEnableOption "set static IP (systemd-networkd)";
          ssid = mkOption {type = lib.types.str;};
          ip = mkOption {type = ip_addr;};
          gateway = mkOption {type = ip_addr;};
          pskFile = mkOption {type = lib.types.str;};
        };
        tailscale.enable = mkEnableOption "tailscale";
        sshd.enable = mkEnableOption "OpenSSH server";
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

      selfhost = {
        navidrome = {
          enable = mkEnableOption "navidrome music server";
          user = mkOption {
            description = "user to run the service as";
            default = config.collinux.user.name;
          };
        };
        adguard.enable = mkEnableOption "AdGuardHome network-wide adblocking";
        caddy.enable = mkEnableOption "caddy https server";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = with config.collinux.services.networking; (iwd.enable && !networkmanager.enable && !static.enable) || (!iwd.enable && networkmanager.enable && !static.enable) || (!iwd.enable && !networkmanager.enable && static.enable);
        message = "only one networking method (iwd, networkmanager, static) can be active";
      }
    ];
  };
}
