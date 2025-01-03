{
  cfgWrapper,
  pkgs,
  my-tmux,
}: let
  config = pkgs.writeText "foot.ini" ''
    [cursor]
    color=181926 f4dbd6

    [colors]
    foreground=cad3f5
    background=24273a

    regular0=494d64
    regular1=ed8796
    regular2=a6da95
    regular3=eed49f
    regular4=8aadf4
    regular5=f5bde6
    regular6=8bd5ca
    regular7=b8c0e0

    bright0=5b6078
    bright1=ed8796
    bright2=a6da95
    bright3=eed49f
    bright4=8aadf4
    bright5=f5bde6
    bright6=8bd5ca
    bright7=a5adcb

    16=f5a97f
    17=f4dbd6

    selection-foreground=cad3f5
    selection-background=454a5f

    search-box-no-match=181926 ed8796
    search-box-match=cad3f5 363a4f

    jump-labels=181926 f5a97f
    urls=8aadf4

    [main]
    font=Iosevka Nerd Font:pixelsize=16
    line-height=22px

    shell=${my-tmux}/bin/tmux
  '';
in
  cfgWrapper {
    pkg = pkgs.foot;
    binName = "foot";
    extraFlags = ["-c ${config}"];
  }
