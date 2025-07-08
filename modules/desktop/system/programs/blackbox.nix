{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.programs.blackbox;
in
  lib.mkIf cfg.enable {
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "com/raggesilver/BlackBox" = {
            context-aware-header-bar = true;
            fill-tabs = true;
            notify-process-completion = true;
            opacity = lib.gvariant.mkInt16 100;
            pixel-scrolling = true;
            pretty = true;
            show-scrollbars = false;
            terminal-padding = lib.gvariant.mkTuple (builtins.map lib.gvariant.mkInt16 [10 10 10 10]);

            floating-controls = false;
            show-headerbar = true;
          };
        };
      }
    ];

    hjem.users."${config.collinux.user.name}".packages = [pkgs.blackbox-terminal];
  }
