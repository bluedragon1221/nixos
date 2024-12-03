{
  pkgs,
  apps ? [],
}: let
  app_cache = "$HOME/.cache/app";
  apps_list = builtins.concatStringsSep "\n" apps;

  launcher = pkgs.writeShellScriptBin "launcher" ''
    echo -e "${apps_list}" | ${pkgs.fzf}/bin/fzf > ${app_cache}
  '';
in
  pkgs.writeShellScriptBin "launcher_window" ''
    ${pkgs.kitty}/bin/kitty --class=launcher ${launcher}/bin/launcher
    hyprctl dispatch exec ${app_cache}

    trap 'rm ${app_cache}' EXIT
  ''
