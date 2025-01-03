{
  cfgWrapper,
  pkgs,
  my-tmux,
}: let
  catppuccin-alacritty = builtins.fetchGit {
    url = "https://github.com/catppuccin/alacritty";
    rev = "f6cb5a5c2b404cdaceaff193b9c52317f62c62f7";
  };

  config = (pkgs.formats.toml {}).generate "config.toml" {
    general = {
      live_config_reload = false;
      import = ["${catppuccin-alacritty}/catppuccin-macchiato.toml"];
    };

    terminal = {
      shell = "${my-tmux}/bin/tmux";
    };
  };
in
  cfgWrapper {
    pkg = pkgs.alacritty;
    binName = "alacritty";
    extraFlags = ["--config-file ${config}"];
  }
