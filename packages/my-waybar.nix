{
  cfgWrapper,
  pkgs,
}: let
  config = (pkgs.formats.json {}).generate "config.jsonc" {
    spacing = 4;
    modules-left = ["hyprland/workspaces"];
    modules-center = ["hyprland/window"];
    modules-right = ["wireplumber" "battery" "clock"];

    "hyprland/workspaces" = {
      disable-scroll = true;
      all-outputs = true;
      warp-on-scroll = false;
      format = "{icon}";
      format-icons = {
        "1" = "";
        "2" = "";
        "3" = "";
        "4" = "";
        "5" = "";
      };
    };
    "hyprland/window".format = "<b>{title}</b>";
    "clock" = {
      format = "{:%I:%M}";
      format-alt = "/{:%Y/%b/%d-%a}";
      tooltip = false;
    };
    "battery" = {
      format = "{icon} {capacity}%";
      format-alt = "{icon}";
      format-icons = [" " " " " " " " " "];
    };
    "wireplumber" = {
      format = "{icon} {volume}%";
      format-alt = "{icon}";
      format-muted = "󰖁 {volume}%";
      format-icons.default = ["󰕿" "󰖀" "󰕾"];
    };
  };

  catppuccin = builtins.fetchGit {
    url = "https://github.com/catppuccin/waybar";
    rev = "ee8ed32b4f63e9c417249c109818dcc05a2e25da";
  };

  style = pkgs.writeText "style.css" ''
    @import "${catppuccin}/themes/macchiato.css";

    * {
      font-family: Iosevka Nerd Font;
      font-size: 10pt;
      min-height: 0;
    }

    #waybar {
      background: @base;
      color: @text;
    }

    #workspaces {
      background-color: @surface0;
      padding: 0rem 0.75rem;
      margin: 5px 0;
      margin-left: 1rem;
      border-radius: 1rem;
    }

    #workspaces button {
      color: @lavender;
      border-radius: 1rem;
      padding: 0rem 0.75rem;
    }

    #workspaces button.active {
      color: @sky;
    }

    #workspaces button:hover {
      box-shadow: inherit;
      text-shadow: inherit;
      background: none;
      border: none;
      border-color: transparent;
      padding: 0 0.75rem;
      margin: 0;
    }

    #custom-music,
    #tray,
    #backlight,
    #clock,
    #battery,
    #wireplumber,
    #custom-lock,
    #custom-power {
      background-color: @surface0;
      padding: 0.5rem 1rem;
      margin: 5px 0;
    }


    #wireplumber {
      color: @maroon;
      border-radius: 1rem 0px 0px 1rem;
      margin-left: 1rem;
    }

    #battery {
      color: @green;
    }

    #clock {
      color: @blue;
      border-radius: 0px 1rem 1rem 0px;
      margin-right: 1rem;
    }
  '';
in
  cfgWrapper {
    pkg = pkgs.waybar;
    binName = "waybar";
    postBuild = ''
      rm $out/etc/xdg/waybar/*
      cp ${config} $out/etc/xdg/waybar/config.jsonc
      cp ${style} $out/etc/xdg/waybar/style.css
    '';
  }
