{
  cfgWrapper,
  pkgs,
  ...
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

  mini-settings = pkgs.writeText "config" ''
    [general]
    bars = 12

    [output]
    method = raw
    raw_target = /tmp/cava.fifo
    data_format = ascii
    ascii_max_range = 7
  '';

  mini-cava-script = pkgs.writeShellScriptBin "mini-cava.sh" ''
    # set up pipe
    mkfifo /tmp/cava.fifo
    trap 'unlink /tmp/cava.fifo' EXIT

    # run cava in the background
    cava -p ${mini-settings} &

    # set up terminal
    clear
    tput civis
    trap 'tput cnorm' EXIT

    # read data from fifo
    while read -r cmd; do
      tput cup 0 0
      echo $cmd | sed "s/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;"
    done < /tmp/cava.fifo
  '';
in
  cfgWrapper {
    pkg = pkgs.cava;
    binName = "cava";

    extraFlags = ["-p ${settings}"];

    extraPkgs = [mini-cava-script];
    hidePkgs = false;
  }
