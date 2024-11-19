{ pkgs, ... }: {
  pkg, binName,
  extraFlags ? [],
  extraPkgs ? [],
  extraEnv ? {},
  files ? {},
  postBuild ? "",
  hidePkgs ? false,
}: let
  extraFlagsArgs = extraFlags
    |> builtins.map (x: ''--add-flags "${x}" '')
    |> builtins.concatStringsSep " ";

  pathArg = if (extraPkgs != [])
    then ''--prefix PATH : "${pkgs.lib.makeBinPath extraPkgs}"''
    else "";

  # Looks like {
  #   VAR = "value";
  #   VAR2 = "value_again";
  # }
  envArgs = extraEnv
    |> builtins.mapAttrs (k: v: ''--set ${k} "${v}"'')
    |> builtins.attrValues
    |> builtins.concatStringsSep " ";

  fileSetup = files
    |> pkgs.lib.mapAttrsToList (filename: contentFn: ''
      mkdir -p "$(dirname $out/${filename})"
      echo '${contentFn "$out"}' > "$out/${filename}"
    '')
    |> builtins.concatStringsSep "";

  wrapped-program = pkgs.symlinkJoin {
    name = binName;
    paths = [ pkg ] ++ extraPkgs;

    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      ${fileSetup}
      ${postBuild}

      wrapProgram $out/bin/${binName} ${extraFlagsArgs} ${pathArg} ${envArgs}
    '';
  };
in if (hidePkgs) then (pkgs.linkFarm "wrapped-${binName}" [
  {
    name = "bin/${binName}";
    path = "${wrapped-program}/bin/${binName}";
  }
]) else wrapped-program

