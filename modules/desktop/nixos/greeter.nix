{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop;
in {
  services.xserver.displayManager.gdm = lib.mkIf (cfg.greeter == "gdm") {
    enable = true;
    wayland = true;
  };

  services.greetd = lib.mkIf (cfg.greeter == "greetd") {
    enable = true;
    settings = rec {
      initial_session = {
        command =
          if cfg.hyprland.useUwsm
          then "${pkgs.uwsm}/bin/uwsm start default"
          else "${config.programs.hyprland.package}/bin/Hyprland";
        user = "collin";
      };
      default_session = initial_session;
    };
  };
}
