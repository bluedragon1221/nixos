{
  subAll,
  cfgWrapper,
  pkgs,
  my-fuzzel,
}: let
  config = import ./config.nix {inherit pkgs my-fuzzel;};

  style = subAll ./style.scss {
    colors = ./catppuccin.scss;
  };
in
  cfgWrapper {
    pkg = pkgs.waybar;
    extraFlags = ["-c ${config}" "-s ${style}"];
  }
