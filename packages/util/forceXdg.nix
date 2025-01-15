{pkgs}: {
  pkg,
  binName,
  preDelete ? [],
}: let
  force-xdg = builtins.fetchGit {
    url = "https://github.com/polirritmico/force-xdg";
    rev = "430930df9c5fb232d9ed3daefe908f51332b16ed";
  };

  rm-script = pkgs.lib.pipe preDelete [
    (builtins.map (x: ''rm -rf ${x}''))
    (builtins.concatStringsSep " ")
  ];
in
  pkgs.writeShellApplication {
    name = binName;
    runtimeInputs = [pkg];
    text = ''
      ${rm-script}

      ${force-xdg}/force-xdg ${binName}
    '';
  }
