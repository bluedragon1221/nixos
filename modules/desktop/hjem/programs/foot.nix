{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.programs.foot;

  settings = {
    main = {
      font = "Iosevka Nerd Font:size=12";
      shell = "${pkgs.fish}/bin/fish";
    };

    colors = with config.collinux.palette; {
      alpha = "0.6";

      foreground = base05;
      background = base00;
      regular0 = base01;
      regular1 = base08;
      regular2 = base11;
      regular3 = base10;
      regular4 = base13;
      regular5 = base14;
      regular6 = base12;
      regular7 = base06;
      bright0 = base02;
      bright1 = base08;
      bright2 = base11;
      bright3 = base10;
      bright4 = base13;
      bright5 = base14;
      bright6 = base12;
      bright7 = base07;
      "16" = base09;
      "17" = base15;
      "18" = base01;
      "19" = base02;
      "20" = base04;
      "21" = base06;
    };
  };
in
  lib.mkIf cfg.enable {
    files = {
      ".config/foot/foot.ini" = {
        generator = lib.generators.toINI {};
        value = settings;
      };
    };

    packages = [pkgs.foot];
  }
