{pkgs}: {
  pkg,
  binName,
}: let
  force-xdg = builtins.fetchGit {
    url = "https://github.com/polirritmico/force-xdg";
    rev = "430930df9c5fb232d9ed3daefe908f51332b16ed";
  };
in
  pkgs.writeShellApplication {
    name = "binName";
    runtimeInputs = [pkg];
    text = ''${force-xdg}/force-xdg ${binName}'';
  }
