{pkgs}: {
  pkg,
  binName,
  extraFlags ? [],
  extraWrapperFlags ? [],
  extraPkgs ? [],
  extraEnv ? {},
  postBuild ? "",
  hidePkgs ? false,
  reducePath ? false,
}: let
  extraFlagsArgs = pkgs.lib.pipe extraFlags [
    (builtins.map (x: ''--add-flags "${x}" ''))
    (builtins.concatStringsSep " ")
  ];

  extraWrapperFlagsArgs = builtins.concatStringsSep " " extraWrapperFlags;

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

  extraPkgs2 =
    if reducePath
    then
      (pkgs.symlinkJoin {
        name = "${binName}-extra-pkgs";
        paths = extraPkgs;
      })
    else extraPkgs;

  wrapped-program = pkgs.symlinkJoin {
    name = binName;
    paths = [pkg] ++ extraPkgs2;

    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      ${postBuild}

      wrapProgram $out/bin/${binName} ${extraFlagsArgs} ${pathArg} ${envArgs} ${extraWrapperFlagsArgs}
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
