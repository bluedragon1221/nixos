{
  pkgs,
  my-kitty,
  my-cava,
  my-cmus,
}: let
  kitty-session = pkgs.writeText "session.conf" ''
    layout splits
    launch --var window=first ${my-cmus}/bin/cmus
    launch --location=hsplit --bias 30 ${my-cava}/bin/cava
    focus_matching_window var:window=first
    launch --location=vsplit --bias 20 ${my-cmus}/bin/album-art.sh
  '';
in
  pkgs.writeShellScriptBin "kitty-music" ''${my-kitty}/bin/kitty --session ${kitty-session} -o dim_opacity=1''
