{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.desktop.wm.components.tofi;
  flags = {
    drun-launch = "true";
    anchor = "bottom";
    horizontal = "true";
    width = "100%";
    height = 20;
    font-size = 12;
    prompt-text = "";
    font = "${pkgs.iosevka}/share/fonts/truetype/Iosevka-Regular.ttf";
    outline-width = 0;
    border-width = 0;
    num-results = 20;
    min-input-width = 0;
    result-spacing = 10;
    padding-top = 0;
    padding-bottom = 0;
    padding-left = 0;
    padding-right = 0;
    background-color = "#11111b";
    text-color = "#585B70";
    selection-color = "#CDD6F4";
    selection-match-color = "#89B4FA";
  };
  flagsText = flags |> lib.mapAttrsToList (k: v: "--${k}=${toString v}") |> lib.concatStringsSep " ";
in
  lib.mkIf cfg.enable {
    packages = [
      (pkgs.writeShellScriptBin "tofi" ''
        ${pkgs.tofi}/bin/tofi ${flagsText}
      '')
      (pkgs.writeShellScriptBin "tofi-drun" ''
        ${pkgs.tofi}/bin/tofi-drun ${flagsText}
      '')
    ];
  }
