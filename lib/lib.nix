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

  netTypes = {lib, ...}: {
    ipAddr = lib.types.strMatching "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$";
    ipAddrCidr = lib.types.strMatching "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])/(3[0-2]|[12]?[0-9])$";
  };

  options = {
    lib,
    config,
  }: let
    inherit (lib) mkOption mkEnableOption;

    mkThemeOption = name:
      mkOption {
        description = "Pre-made theme for ${name}";
        type = lib.types.enum ["catppuccin" "adwaita" "kanagawa" "terminal"];
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
  inherit netTypes;

  flatten = builtins.foldl' (a: b: a ++ b) [];
}
