{lib, ...}: let
  inherit (lib) mkOption;
in {
  options = {
    collinux.secrets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule ({config, ...}: {
          options = {
            name = mkOption {
              type = lib.types.str;
              default = config._module.args.name;
            };
            file = mkOption {type = lib.types.path;};
            mode = mkOption {
              type = lib.types.str;
              default = "0400";
            };
            owner = mkOption {
              type = lib.types.str;
              default = "0";
            };
            path = mkOption {
              type = lib.types.str;
              default = "/run/secrets.d/${config.name}";
            };
          };
        })
      );
      default = {};
    };
  };
}
