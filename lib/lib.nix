let
  optionalAttrs = cond: as:
    if cond
    then as
    else {};

  mkIfNull = cond: as:
    if cond
    then as
    else null;

  globimport = {
    lazyImport = path: optionalAttrs (builtins.pathExists path) (import path);

    getSubdirs = dir:
      builtins.filter (x: x != null)
      (builtins.attrValues
        (builtins.mapAttrs
          (name: value: mkIfNull (value == "directory") name)
          (builtins.readDir dir)));

    getSubfiles = dir:
      builtins.filter (x: x != null)
      (builtins.attrValues
        (builtins.mapAttrs
          (name: value: mkIfNull (value == "file") name)
          (builtins.readDir dir)));
  };

  options = {
    lib,
    config,
  }: let
    inherit (lib) mkOption mkEnableOption;

    mkThemeOption = name:
      mkOption {
        description = "Pre-made theme for ${name}";
        type = lib.types.enum ["catppuccin" "adwaita" "kanagawa"];
        default = config.collinux.theme;
        defaultText = "config.collinux.theme";
      };

    mkProgramOption = name: {
      enable = mkEnableOption "whether to enable ${name}";
      theme = mkThemeOption name;
    };
  in {
    inherit mkProgramOption mkThemeOption;
  };
in {
  inherit globimport;
  inherit options;

  flatten = builtins.foldl' (a: b: a ++ b) [];
}
