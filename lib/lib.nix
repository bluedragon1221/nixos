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
    mkProgramOption' = name: extraOpts:
      {
        enable = mkEnableOption "whether to enable ${name}";
        theme = mkOption {
          type = lib.types.enum ["catppuccin" "adwaita"];
          default = config.collinux.terminal.theme;
        };
      }
      // extraOpts;

    mkProgramOption = name: mkProgramOption' name {};
  in {
    inherit mkProgramOption' mkProgramOption;
  };
in {
  inherit globimport;
  inherit options;
}
