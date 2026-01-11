{lib, ...}: let
  inherit (lib) mkOption;
in {
  options = {
    collinux.secrets = lib.mkOption {
      description = "Atribute set of secrets";
      type = lib.types.attrsOf (
        lib.types.submodule ({config, ...}: {
          options = {
            name = mkOption {
              type = lib.types.str;
              default = config._module.args.name;
              internal = true;
            };
            file = mkOption {
              description = "Name of the file in the /run/secrets.d";
              type = lib.types.path;
            };
            mode = mkOption {
              description = "Permissions mode of the decrypted secret in a format understood by chmod";
              type = lib.types.str;
              default = "0400";
            };
            owner = mkOption {
              description = "Owner of the decrypted secret file";
              type = lib.types.str;
              default = "0";
            };
            path = mkOption {
              type = lib.types.str;
              default = "/run/secrets.d/${config.name}";
              description = "Path where the decrypted secret is installed";
            };
          };
        })
      );
      default = {};
    };
  };
}
