{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.cmus;
in
  lib.mkIf cfg.enable {
    home.file."${config.xdg.configHome}/cmus/catppuccin.theme".source = ./catppuccin.theme;

    programs.cmus = let
      status-display = pkgs.writeShellScriptBin "status.sh" ''
        while [ $# -ge 2 ]; do
        	eval _$1='$2'
        	shift
        	shift
        done

        [ -d ~/.local/share/cmus ] || mkdir ~/.local/share/cmus

        if [ -n "$_file" ]; then
        	${pkgs.ffmpeg}/bin/ffmpeg -i "$_file" -y -an -c:v copy ~/.local/share/cmus/curr_cover.jpg || rm ~/.local/share/cmus/curr_cover.jpg
        fi

        if [[ "$_status" = "playing" ]]; then
          notify-send -t 3000 -u low -i ~/.local/share/cmus/curr_cover.jpg "Now Playing: $_title" "$_artist"
        fi
      '';
    in {
      enable = true;
      theme = lib.mkIf (config.collinux.theme == "catppuccin") "catppuccin";
      extraConfig = ''
        set status_display_program=${status-display}/bin/status.sh
      '';
    };
  }
