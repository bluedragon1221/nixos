{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.services.btopweb;

  btopSettings = pkgs.writeText "btop.conf" ''
    color_theme = "tomorrow-night"
    enable_mouse = true
    background_update = false

    proc_tree = true
    proc_colors = true
  '';
in {
  config = lib.mkIf cfg.enable {
    users.groups."btopweb" = {};
    users.users."btopweb" = {
      isSystemUser = true;
      group = "btopweb";
    };
    users.users.caddy.extraGroups = ["btopweb"];

    systemd.services."btopweb" = {
      description = "Host btop on a website";
      restartIfChanged = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "btopweb";
        Group = "btopweb";
        Type = "simple";

        RuntimeDirectory = "btopweb";
        RuntimeDirectoryMode = "0770";
        UMask = "0007";

        ExecStart = ''
          ${lib.getExe pkgs.ttyd} \
            -W \
            -i /run/btopweb/ttyd.sock \
            -t renderType=canvas \
            -t fontSize=16 \
            ${pkgs.btop}/bin/btop -c ${btopSettings}
        '';
      };
    };

    services.caddy.virtualHosts."btop.ganymede".extraConfig = ''
      tls internal
      reverse_proxy unix//run/btopweb/ttyd.sock
    '';

    collinux.services.glance.homelabServices."btop" = {
      url = "https://btop.ganymede";
      icon = "si:htop";
    };
  };
}
