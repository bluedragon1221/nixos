{
  cfgWrapper,
  pkgs,
  my-fish,
}: let
  catppuccin_kitty = builtins.fetchGit {
    url = "https://github.com/catppuccin/kitty";
    rev = "1f99e6682d84fe4d8e3177d3add8d0591607a2ac";
  };

  smart_splits = builtins.fetchGit {
    url = "https://github.com/mrjones2014/smart-splits.nvim";
    rev = "aa657c1a0ac5556fb268c4cf063e876117d0edd6";
  };

  settings = pkgs.writeTextFile {
    destination = "/kitty.conf";
    name = "kitty-config";
    text = ''
      include ${catppuccin_kitty}/themes/macchiato.conf

      shell ${my-fish}/bin/fish

      font_family Iosevka Nerd Font
      # font_family Monocraft
      font_size 13
      adjust_line_height 3
      allow_remote_control yes
      confirm_os_window_close 0
      enabled_layouts splits:split_axis=horizontal
      hide_window_decorations yes
      inactive_text_alpha 0.3

      window_border_width 2
      window_margin_width 0
      window_padding_width 5
      background_opacity 0.7
      transparent_background_colors #303347@0.7

      tab_bar_align left
      tab_bar_edge bottom
      tab_bar_min_tabs 2
      tab_bar_style powerline
      tab_powerline_style slanted

      map ctrl+enter launch --location=split --cwd=current
      map ctrl+shift+r load_config_file
      map ctrl+t new_tab
      map ctrl+w close_window

      map ctrl+shift+left kitten relative_resize.py left 2
      map ctrl+shift+right kitten relative_resize.py right 2
      map ctrl+shift+up kitten relative_resize.py up 1
      map ctrl+shift+down kitten relative_resize.py down 1
    '';
  };

  kitty-dir = pkgs.symlinkJoin {
    name = "kitty-dir";
    paths = [
      settings
      (pkgs.writeTextFile {
        destination = "/relative_resize.py";
        name = "relative_resize";
        text = builtins.readFile "${smart_splits}/kitty/relative_resize.py";
      })
    ];
  };
in
  cfgWrapper {
    pkg = pkgs.kitty;
    binName = "kitty";
    extraEnv.KITTY_CONFIG_DIRECTORY = kitty-dir;
    extraFlags = ["--single-instance"];
  }
