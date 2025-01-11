{
  cfgWrapper,
  pkgs,
}: let
  tmux-bar = pkgs.runCommand "tmux-bar" {} ''
    mkdir -p $out/bin
    tmux=${pkgs.tmux} substituteAll ${./tmux-bar.sh} $out/bin/tmux-bar.sh
  '';
in
  cfgWrapper {
    pkg = pkgs.tmux;
    binName = "tmux";
    extraBin = [tmux-bar];
    extraFlags = ["-f ${./tmux.conf}"];
  }
