{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.programs.firefox;
in
  lib.mkIf cfg.enable {
    files.".mozilla/firefox/profiles.ini" = {
      generator = lib.generators.toINI {};
      value = {
        Profile0 = {
          Name = "collin";
          IsRelative = 1;
          Path = "collin";
          Default = 1;
        };
        General = {
          StartWithLastProfile = 1;
          Version = 2;
        };
      };
    };
    packages = [pkgs.firefox];
  }
