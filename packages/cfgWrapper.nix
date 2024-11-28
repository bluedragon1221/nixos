{pkgs}: {
  pkg,
  binName,
  extraFlags ? [],
  extraPkgs ? [],
  extraEnv ? {},
  postBuild ? "",
  hidePkgs ? false,
}: let
  extraFlagsArgs = pkgs.lib.pipe extraFlags [
    (builtins.map (x: ''--add-flags "${x}" ''))
    (builtins.concatStringsSep " ")
  ];

  pathArg =
    if (extraPkgs != [])
    then ''--prefix PATH : "${pkgs.lib.makeBinPath extraPkgs}"''
    else "";

  # Looks like {
  #   VAR = "value";
  #   VAR2 = "value_again";
  # }
  envArgs = pkgs.lib.pipe extraEnv [
    (builtins.mapAttrs (k: v: ''--set ${k} "${v}"''))
    builtins.attrValues
    (builtins.concatStringsSep " ")
  ];

  wrapped-program = pkgs.symlinkJoin {
    name = binName;
    paths = [pkg] ++ extraPkgs;

    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      ${postBuild}

      wrapProgram $out/bin/${binName} ${extraFlagsArgs} ${pathArg} ${envArgs}
    '';
  };
in
  if hidePkgs
  then
    (pkgs.linkFarm "wrapped-${binName}" [
      {
        name = "bin/${binName}";
        path = "${wrapped-program}/bin/${binName}";
      }
    ])
  else wrapped-program
