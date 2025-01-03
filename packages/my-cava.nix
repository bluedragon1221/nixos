{
  cfgWrapper,
  pkgs,
}: let
  settings = pkgs.writeText "cava" ''
    [color]
    gradient = 1
    gradient_color_1 = "#8bd5ca"
    gradient_color_2 = "#91d7e3"
    gradient_color_3 = "#7dc4e4"
    gradient_color_4 = "#8aadf4"
    gradient_color_5 = "#c6a0f6"
    gradient_color_6 = "#f5bde6"
    gradient_color_7 = "#ee99a0"
    gradient_color_8 = "#ed8796"

    [general]
    autosens = 1
    framerate = 60

    [input]
    method = pipewire
    source = auto

    [smoothing]
    monstercat = 0
    noise_reduction = 70
    waves = 0
  '';
in
  cfgWrapper {
    pkg = pkgs.cava;
    binName = "cava";
    extraFlags = ["-p ${settings}"];
  }
