{
  cfgWrapper,
  substituteAll,
  pkgs,
}: let
  tmux-bar = substituteAll ./tmux-bar.sh {
    "tmux" = pkgs.tmux;
  };
in
  cfgWrapper {
    pkg = pkgs.tmux;
    binName = "tmux";
    extraPkgs = [tmux-bar];
    extraFlags = ["-f ${./tmux.conf}"];
  }
