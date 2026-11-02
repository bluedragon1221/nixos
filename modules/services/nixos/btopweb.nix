{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.services.btopweb;
in {
  config = lib.mkIf cfg.enable {
    system.services."btopweb" = {
      _module.args = {inherit pkgs;};
      imports = [./service_modules/btopweb.nix];

      caddy = {
        virtualHost = "btop.ganymede";
        internal = true;
      };

      btopweb = {
        btopSettings = ''
          color_theme = "tomorrow-night"
          enable_mouse = true
          background_update = false

          proc_tree = true
          proc_colors = true
        '';
      };
    };

    collinux.services.glance.homelabServices."btop" = {
      url = "https://btop.ganymede";
      icon = "si:htop";
    };
  };
}
