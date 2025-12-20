{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.cmus;

  cmus_theme_kanagawa = ''
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

  cmus_theme_catppuccin = ''
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
    colorscheme ${cfg.theme}
  '';
in
  lib.mkIf cfg.enable {
    files =
      {
        ".config/cmus/rc".text = cmus_rc;
      }
      // (lib.mkIf (cfg.theme == "catppuccin") {
        ".config/cmus/catppuccin.theme".text = cmus_theme_catppuccin;
      })
      // (lib.mkIf (cfg.theme == "kanagawa") {
        ".config/cmus/kanagawa.theme".text = cmus_theme_kanagawa;
      });

    packages = [pkgs.cmus];
  }
