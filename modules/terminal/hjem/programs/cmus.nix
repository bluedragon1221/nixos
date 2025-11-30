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

    ${pkgs.dunst}/bin/dunstify -t 2000 -u low -h string:x-canonical-private-synchronous:music -i ~/.local/share/cmus/curr_cover.jpg "$_status: $_title" "$_artist"
  '';

  cmus_theme = ''
    set color_cmdline_error=lightred
    set color_cmdline_info=lightyellow
    set color_cmdline_fg=lightred
    set color_cmdline_bg=237
    set color_separator=238
    set color_statusline_bg=blue
    set color_statusline_fg=233
    set color_titleline_bg=237
    set color_titleline_fg=white
    set color_win_bg=black
    set color_win_fg=241
    set color_win_cur=lightgreen
    set color_win_cur_sel_bg=green
    set color_win_cur_sel_fg=233
    set color_win_dir=lightblue
    set color_win_fg=white
    set color_win_inactive_cur_sel_bg=016
    set color_win_inactive_cur_sel_fg=233
    set color_win_sel_bg=237
    set color_win_sel_fg=white
    set color_win_title_bg=237
    set color_win_title_fg=lightred
  '';

  cmus_rc = ''
    colorscheme all
    set status_display_program=${scriptsDir}/status.sh
  '';
in
  lib.mkIf cfg.enable {
    files = let
      e = text: {
        inherit text;
        executable = true;
      };
    in {
      ".config/cmus/scripts/status.sh" = e scripts.statusDisplay;

      ".config/cmus/rc".text = cmus_rc;
      ".config/cmus/all.theme".text = cmus_theme;
    };

    packages = [pkgs.cmus];
  }
