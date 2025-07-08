{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.cmus;

  scriptsDir = "~/.config/cmus/scripts";

  scripts.statusDisplay = ''
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

  cmus_theme = ''
    set color_cmdline_bg=default
    set color_cmdline_fg=default
    set color_error=211
    set color_info=223
    set color_separator=8
    set color_statusline_bg=default
    set color_statusline_fg=default
    set color_titleline_bg=183
    set color_titleline_fg=8
    set color_titleline_attr=bold
    set color_win_bg=default
    set color_win_cur=117
    set color_win_cur_sel_bg=117
    set color_win_cur_sel_fg=235
    set color_win_dir=default
    set color_win_fg=default
    set color_win_inactive_cur_sel_bg=0
    set color_win_inactive_cur_sel_fg=default
    set color_win_inactive_sel_bg=0
    set color_win_inactive_sel_fg=default
    set color_win_sel_bg=15
    set color_win_sel_fg=235
    set color_win_title_bg=default
    set color_win_title_fg=183
    set color_win_title_attr=bold
  '';

  cmus_rc = ''
    ${
      if (cfg.theme == "catppuccin")
      then "colorscheme catppuccin"
      else ""
    }
    set status_display_program=${scriptsDir}/status.sh
  '';

  cava_config =
    if cfg.theme == "catppuccin"
    then ''
      [color]
      gradient=1
      gradient_color_1='#94e2d5'
      gradient_color_2='#89dceb'
      gradient_color_3='#74c7ec'
      gradient_color_4='#89b4fa'
      gradient_color_5='#cba6f7'
      gradient_color_6='#f5c2e7'
      gradient_color_7='#eba0ac'
      gradient_color_8='#f38ba8'
    ''
    else "";
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/cmus/scripts/status.sh".text = scripts.statusDisplay;

        ".config/cmus/rc".text = cmus_rc;
        ".config/cmus/catppuccin.theme".text = lib.mkIf (cfg.theme == "catppuccin") cmus_theme;
        ".config/cava/config".text = cava_config;
      };

      packages = with pkgs; [cava cmus];
    };
  }
