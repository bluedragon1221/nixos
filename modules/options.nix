{
  lib,
  config,
  my-lib,
  ...
}: let
  inherit (lib) mkOption;
  inherit (my-lib.options {inherit lib config;}) mkThemeOption;
in {
  options = {
    collinux.theme = mkThemeOption "The entire system";

    collinux.palette = let
      colorOption = lib.mkOption {
        type = lib.types.strMatching "^([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$";
        internal = true;
      };
    in
      mkOption {
        internal = true;
        type = lib.types.submodule {
          options = {
            base00 = colorOption;
            base01 = colorOption;
            base02 = colorOption;
            base03 = colorOption;
            base04 = colorOption;
            base05 = colorOption;
            base06 = colorOption;
            base07 = colorOption;
            base08 = colorOption;
            base09 = colorOption;
            base10 = colorOption;
            base11 = colorOption;
            base12 = colorOption;
            base13 = colorOption;
            base14 = colorOption;
            base15 = colorOption;
          };
        };
        default =
          if (config.collinux.theme == "catppuccin")
          then {
            base00 = "1E1E2E";
            base01 = "181825";
            base02 = "313244";
            base03 = "45475A";
            base04 = "585B70";
            base05 = "CDD6F4";
            base06 = "F5E0DC";
            base07 = "B4BEFE";
            base08 = "F38BA8";
            base09 = "FAB387";
            base10 = "F9E2AF";
            base11 = "A6E3A1";
            base12 = "94E2D5";
            base13 = "89B4FA";
            base14 = "CBA6F7";
            base15 = "F2CDCD";
          }
          else if (config.collinux.theme == "adwaita")
          then {
            base00 = "1D1D1D";
            base01 = "303030";
            base02 = "3D3846";
            base03 = "77767B";
            base04 = "B0AFAC";
            base05 = "DEDDDA";
            base06 = "F6F5F4";
            base07 = "FCFCFC";
            base08 = "E01B24";
            base09 = "FF7800";
            base10 = "F5C211";
            base11 = "33D17A";
            base12 = "33B2A4";
            base13 = "3584E4";
            base14 = "9141AC";
            base15 = "986A44";
          }
          else if (config.collinux.theme == "kanagawa")
          then {
            base00 = "1F1F28";
            base01 = "16161D";
            base02 = "223249";
            base03 = "54546D";
            base04 = "727169";
            base05 = "DCD7BA";
            base06 = "C8C093";
            base07 = "717C7C";
            base08 = "C34043";
            base09 = "FFA066";
            base10 = "C0A36E";
            base11 = "76946A";
            base12 = "6A9589";
            base13 = "7E9CD8";
            base14 = "957FB8";
            base15 = "D27E99";
          }
          else {};
      };
  };
}
