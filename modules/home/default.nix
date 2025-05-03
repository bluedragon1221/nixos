{
  pkgs,
  lib,
  config,
}: let
  inherit (lib) mkOption types;
in {
  options = {
    collinux = mkOption {
      type = types.submodule {
        options = {
          terminal = types.submodule (import ./terminal);
        };
      };
    };
  };
}
