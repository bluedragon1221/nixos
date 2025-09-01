{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.desktop.programs.alacritty;
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files.".config/alacritty/alacritty.toml" = {
        value = {
          general = {
            import = ["keys.toml" "colors.toml"];
            live_config_reload = true;
          };
          font = {
            normal.family = "Iosevka Nerd Font";
            size = 12;
          };
        };
        generator = (pkgs.formats.toml {}).generate "alacritty.toml";
      };

      files.".config/alacritty/colors.toml".text = ''
        [colors]
        draw_bold_text_with_bright_colors = false

        # Default colors
        [colors.primary]
        background = '#242424'
        foreground = '#C5C6C5'

        # Colors the cursor will use if `custom_cursor_colors` is true
        [colors.cursor]
        text = '#2D3234'
        cursor = '#C5C6C5'

        # Normal colors
        [colors.normal]
        black = '#2D3234'
        red = '#FFA500'
        green = '#6FEE91'
        yellow = '#91EE6F'
        blue = '#916FB4'
        magenta = '#EE6F91'
        cyan = '#6F91B4'
        white = '#C5C6C5'

        # Bright colors
        [colors.bright]
        black = '#566164'
        red = '#FFFF60'
        green = '#33393B'
        yellow = '#4B5356'
        blue = '#919494'
        magenta = '#D3D4D5'
        cyan = '#EE6F6F'
        white = '#EEEEEC'
      '';

      files.".config/alacritty/keys.toml".text = ''
        [[keyboard.bindings]]
        chars = "\u001b[27;5;9~"
        key = "Tab"
        mods = "Control"

        [[keyboard.bindings]]
        chars = "\u001b[27;5;13~"
        key = "Enter"
        mods = "Control"
      '';

      packages = [pkgs.alacritty];
    };
  }
