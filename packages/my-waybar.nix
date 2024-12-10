{
  cfgWrapper,
  pkgs,
  my-fuzzel,
}: let
  power_menu = pkgs.writeText "power_menu.xml" ''
      <?xml version="1.0" encoding="UTF-8"?>
    <interface>
      <object class="GtkMenu" id="menu">
        <child>
      		<object class="GtkMenuItem" id="logout">
      			<property name="label">Log Out</property>
          </object>
      	</child>
        <child>
          <object class="GtkSeparatorMenuItem" id="delimiter1"/>
        </child>
        <child>
      		<object class="GtkMenuItem" id="reboot">
      			<property name="label">Reboot</property>
      		</object>
        </child>
        <child>
          <object class="GtkMenuItem" id="shutdown">
      			<property name="label">Shutdown</property>
          </object>
        </child>
      </object>
    </interface>
  '';

  config = (pkgs.formats.json {}).generate "config.jsonc" {
    spacing = 4;
    modules-left = ["custom/launcher" "hyprland/workspaces"];
    modules-center = ["hyprland/window"];
    modules-right = ["bluetooth" "wireplumber" "battery" "clock" "custom/power"];

    "custom/launcher" = {
      format = " ";
      on-click = "${my-fuzzel}/bin/fuzzel";
    };
    "hyprland/workspaces" = {
      disable-scroll = true;
      all-outputs = true;
      warp-on-scroll = false;
      format = "{icon}";
      format-icons = {
        "1" = "";
        "2" = "󰈹";
        "3" = "󰝚";
        "4" = "󰎚";
        "5" = "";
      };
    };
    "hyprland/window" = {
      on-click = "hyprctl dispatch float";
    };
    "bluetooth" = {
      format = "";
      format-connected = "󰂯 {device_alias}";
      on-click = "blueman-manager";
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
      tooltip = false;
    };
    "clock" = {
      format = "{:%I:%M}";
      format-alt = "/{:%Y/%b/%d-%a}";
      tooltip = false;
    };
    "custom/power" = {
      format = "  collin";
      tooltip = false;
      menu = "on-click";
      menu-file = "${power_menu}";
      menu-actions = {
        logout = "hyprctl dispatch exit";
        reboot = "reboot";
        shutdown = "poweroff";
      };
    };
  };

  catppuccin = builtins.fetchGit {
    url = "https://github.com/catppuccin/waybar";
    rev = "ee8ed32b4f63e9c417249c109818dcc05a2e25da";
  };

  style = pkgs.writeText "style.css" ''
    @import "${catppuccin}/themes/mocha.css";

    * {
      font-family: Iosevka Nerd Font;
      font-size: 10pt;
      min-height: 0;
    }

    #waybar {
      background: @base;
      color: @text;
    }

    #workspaces,
    #clock,
    #battery,
    #wireplumber,
    #bluetooth.connected,
    #custom-power {
      color: @text;
      background: @surface0;

      padding: 0.5rem 1rem;
      border-radius: 1rem;

      margin: 5px 0;
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

    #window {
      font-size: 12pt;
    }

    #custom-launcher {
      color: @blue;
      font-size: 12pt;
      padding: 0;
      margin: 0;

      margin-left: 1rem;
      margin-right: 1rem;
    }

    #bluetooth.connected {
      color: @blue;
    }

    #wireplumber {
      color: @maroon;
      border-radius: 1rem 0 0 1rem;
      margin-left: 1rem;
    }

    #battery {
      color: @green;
      border-radius: 0;
    }

    #clock {
      color: @blue;
      border-radius: 0 1rem 1rem 0;
      margin-right: 1rem;
    }

    #custom-power {
      color: @rosewater;
      margin-right: 1rem;
      /* border: @rosewater 1px solid; */
    }
  '';
in
  cfgWrapper {
    pkg = pkgs.waybar;
    binName = "waybar";
    extraFlags = ["-c ${config}" "-s ${style}"];
  }
