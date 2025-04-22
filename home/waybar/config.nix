{pkgs, ...}: {
  spacing = 4;
  modules-left = ["custom/launcher" "hyprland/workspaces"];
  modules-center = ["hyprland/window"];
  modules-right = ["bluetooth" "wireplumber" "battery" "clock" "custom/power"];

  "custom/launcher" = {
    format = " ";
    on-click = "${pkgs.fuzzel}/bin/fuzzel";
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
    menu-file = "${./power_menu.xml}";
    menu-actions = {
      logout = "hyprctl dispatch exit";
      reboot = "reboot";
      shutdown = "poweroff";
    };
  };
}
