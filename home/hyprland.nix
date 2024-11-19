{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      bind = [
        ", Print, exec, ${pkgs.cmus}/bin/cmus-remote -u"
        "Mod4, b, exec, firefox"
        "Mod4 SHIFT, b, exec, zen"
        "Mod4, x, exec, kitty"
        "Mod4, q, killactive"
        "Mod4 SHIFT, q, exit"

      ] ++ (builtins.concatLists (builtins.genList (i: [
        "Mod4, ${toString i}, workspace, ${toString i}"
        "Mod4 SHIFT, ${toString i}, movetoworkspace, ${toString i}"
      ]) 9));

      binde = let
        set-vol = vol: "wpctl set-volume @DEFAULT_AUDIO_SINK@ ${vol}";
      in [
        ", XF86AudioRaiseVolume, exec, ${set-vol "5%+"}"
        ", XF86AudioLowerVolume, exec, ${set-vol "5%-"}"
      ];

      monitor = [ ", preferred, auto, 1" ];

      general = {
        gaps_in = 5;
        gaps_out = 8;

        border_size = 2;
        resize_on_border = true;
        "col.active_border" = "rgba(c6a0f6ff)";
        "col.inactive_border" = "rgba(24273acc)";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      decoration = {
        rounding = 0;
        shadow.enabled = false;
        blur.enabled = true;
      };

      animations = {
        bezier = [
          "ease,.25,.1,.25,1"
        ];

        animation = [
          "workspaces, 1, 2, ease"
          "global,     1, 2.5, ease"
          "windowsIn,  1, 2.75, ease, slide"
          "windowsOut, 1, 2.75, ease, slide"
        ];
      };
    };
  };

  services.hyprpaper = let
    repo = builtins.fetchGit {
      url = "https://github.com/zhichaoh/catppuccin-wallpapers";
      rev = "ebe75d7ae2c4c002d72e4593c4a39e189c88edcb";
    };

    wallpaper = "${repo}/landscapes/evening-sky.png";
  in {
    enable = true;
    settings = {
      preload = [ wallpaper ];

      wallpaper = [ ",${wallpaper}" ];
    };
  };
}
