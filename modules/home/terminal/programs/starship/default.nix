{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    collinux.terminal.programs.starship = {
      enable = lib.mkEnableOption "starship prompt";
      theme = lib.mkOption {
        type = lib.types.enum ["default" "minimal" "powerline"];
        default = "default";
      };
    };
  };

  config = let
    cfg = config.collinux.terminal.programs.starship;
  in
    lib.mkIf cfg.enable {
      catppuccin.starship.enable = false; # relies on ifd
      programs.starship = {
        enable = true;
        settings =
          if cfg.theme == "minimal"
          then (import ./settings_minimal.nix) # theme agnostic
          else if cfg.theme == "powerline" # only catppuccin
          then (import ./settings_powerline.nix)
          else {};
      };
    };
}
