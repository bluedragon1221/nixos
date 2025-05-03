{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    collinux.terminal.programs.bat = {
      enable = lib.mkEnableOption "bat";
      alias = lib.mkOption {
        type = lib.types.bool;
        description = "alias cat to bat for the default shell (checks config.collinux.shells.<shell>.enable)";
        default = false;
      };
    };
  };

  config = let
    cfg = config.collinux.terminal.programs.bat;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        catppuccin.bat.enable = false; # uses ifd
        programs.bat = {
          enable = true;
          config.theme = "base16"; # looks _good enough_, but a real catppuccin theme would be better
        };
      }
      (lib.mkIf cfg.alias {
        home.shellAliases."cat" = "bat"; # do it this way so it's shell-agnostic
      })
    ]);
}
