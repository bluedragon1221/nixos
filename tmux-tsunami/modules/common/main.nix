{lib, ...}: let
  inherit (lib) mkOption mkEnableOption;
in {
  options = {
    tsunami = {
      enable = mkEnableOption "tsunami tmux distro";
      scripts = mkOption {
        type = lib.types.attrsOf (lib.types.str);
        default = [];
      };

      files = mkOption {
        type = lib.types.attrsOf (lib.types.str);
        default = [];
      };

      confs = mkOption {
        type = lib.types.attrsOf (lib.types.str);
        default = [];
      };
    };
  };
}
