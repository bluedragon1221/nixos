{
  cfgWrapper,
  pkgs,
  my-mako,
}: let
  cache-dir = "$HOME/.local/share/cmus";
  theme = builtins.fetchGit {
    url = "https://github.com/Sekki21956/cmus";
    rev = "e9b01942f26c7cd8c30a367fd349c8a27d1c04c9";
  };

  status-display = pkgs.writeShellScriptBin "status.sh" ''
    while [ $# -ge 2 ]; do
    	eval _$1='$2'
    	shift
    	shift
    done

    [ -d ${cache-dir} ] || mkdir ${cache-dir}

    if [ -n "$_file" ]; then
    	${pkgs.ffmpeg}/bin/ffmpeg -i "$_file" -y -an -c:v copy ${cache-dir}/curr_cover.jpg || rm ${cache-dir}/curr_cover.jpg
    	echo "[$_status] $_album - $_title - $_artist" > ${cache-dir}/curr_song.txt
    fi

    if [[ "$_status" = "playing" ]]; then
      ${my-mako}/bin/notify-send -t 3000 -u low "Now Playing: $_title" "$_artist"
    fi
  '';

  album-art = pkgs.writeShellScriptBin "album-art.sh" ''
    echo "${cache-dir}/curr_song.txt" | ${pkgs.entr}/bin/entr -cs '[ -f ${cache-dir}/curr_cover.jpg ] && kitten icat ${cache-dir}/curr_cover.jpg; cat ${cache-dir}/curr_song.txt'
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

  playlists-dir = pkgs.writeTextFile {
    name = "playlists-dir";
    text = "";
    destination = "/playlists/.git-keep";
  };

  cmus-dir = pkgs.symlinkJoin {
    name = "cmus-dir";
    paths = [
      config
      theme
      playlists-dir
    ];
  };
in
  cfgWrapper {
    pkg = pkgs.cmus;
    binName = "cmus";
    extraPkgs = [album-art];
    extraEnv.CMUS_HOME = cmus-dir;
  }
