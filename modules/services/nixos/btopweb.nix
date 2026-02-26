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
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    users.groups."btopweb" = {};
    users.users."btopweb" = {
      isSystemUser = true;
      group = "btopweb";
    };

    systemd.services."btopweb" = {
      description = "Host btop on a website";
      restartIfChanged = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "btopweb";
        Type = "simple";

        ExecStart = ''${pkgs.ttyd}/bin/ttyd -W -i ${cfg.listenAddr} -p ${toString cfg.port} -t renderType=canvas -t fontSize=16 ${pkgs.btop}/bin/btop -c ${btopSettings}'';
      };
    };
  };
}
