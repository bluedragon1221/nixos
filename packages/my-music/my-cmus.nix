{
  cfgWrapper,
  pkgs,
  my-mako,
}: let
  status-display = pkgs.writeShellScriptBin "status.sh" ''
    while [ $# -ge 2 ]; do
    	eval _$1='$2'
    	shift
    	shift
    done

    [ -d ~/.local/share/cmus ] || mkdir ~/.local/share/cmus

    if [ -n "$_file" ]; then
    	${pkgs.ffmpeg}/bin/ffmpeg -i "$_file" -y -an -c:v copy ~/.local/share/cmus/curr_cover.jpg || rm ~/.local/share/cmus/curr_cover.jpg
    	echo "[$_status] $_album - $_title - $_artist" > ~/.local/share/cmus/curr_song.txt
    fi

    if [[ "$_status" = "playing" ]]; then
      ${my-mako}/bin/notify-send -t 3000 -u low "Now Playing: $_title" "$_artist"
    fi
  '';

  config = pkgs.writeTextFile {
    name = "cmus-config";
    text = ''
      add ~/Music

      set status_display_program=${status-display}/bin/status.sh
      set format_title=cmus: %t - %A

      fset ambient=genre="Ambient"
      fset classical=genre="Classical*"
      fset dubstep=genre="Electronic/Cool"
      fset edm=genre="Electronic*"
      colorscheme catppuccin
    '';
    destination = "/rc";
  };

  cmus-dir = pkgs.symlinkJoin {
    name = "cmus-dir";
    paths = [
      config
      (pkgs.runCommand "playlists-dir" {} ''
        mkdir -p $out/playlists
        cp ${./catppuccin.theme} $out/catppuccin.theme
      '')
    ];
  };
in
  cfgWrapper {
    pkg = pkgs.cmus;
    binName = "cmus"; # pkgs.cmus doesn't have a meta.mainProgram
    extraEnv.CMUS_HOME = cmus-dir;
  }
