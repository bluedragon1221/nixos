{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.broot;

  conf = {
    imports = [
      "skins/catppuccin-mocha.hjson"
    ];

    default_flags = "-g";
    icon_theme = "nerdfont";
    special_paths = {
      "~/ganymede" = {
        show = "never";
        list = "never";
        sum = "never";
      };
      "~/.config".show = "always";
    };

    verbs = [
      {
        name = "edit";
        key = "enter";
        invocation = "e";
        execution = "$EDITOR +{line} {file}";
        working_dir = "{root}";
        apply_to = "file";
        leave_broot = false;
      }
      {
        name = "touch";
        invocation = "touch {filename}";
        execution = "touch {filename}";
        working_dir = "{directory}";
        apply_to = "directory";
        leave_broot = false;
      }
      {
        name = "lazygit";
        key = "ctrl-g";
        invocation = "lazygit";
        execution = "lazygit";
        working_dir = "{root}";
        leave_broot = false;
      }
      {
        invocation = "opencode {extraargs}";
        execution = "opencode {extraargs}";
        working_dir = "{root}";
        leave_broot = false;
      }
      {
        name = "justfile";
        key = "ctrl-j";
        execution = ''just --choose --chooser "fzf --height=25% --color=bg:-1 --preview 'just --show {}'"'';
        working_dir = "{root}";
        leave_broot = false;
      }
      {
        name = "terminal";
        key = "ctrl-t";
        execution = "$SHELL";
        working_dir = "{root}";
        leave_broot = false;
      }
      {
        key = "alt-enter";
        execution = "swaymsg exec -- foot -D '{root}' fish -c 'br'";
        leave_broot = false;
      }
      {
        key = "ctrl-a";
        internal = "toggle_stage";
      }
      {
        key = "ctrl-h";
        cmd = ":input_clear;:focus ~";
      }
    ];
  };
in
  lib.mkIf cfg.enable {
    files =
      {
        ".config/broot/conf.hjson" = {
          generator = (pkgs.formats.json {}).generate "broot-conf.hjson";
          value = conf;
        };
      }
      // (lib.optionalAttrs config.collinux.terminal.shells.fish.enable {
        ".config/fish/conf.d/broot.fish".text = ''
          broot --print-shell-function fish | source
        '';
      })
      // (lib.optionalAttrs config.collinux.terminal.shells.bash.enable {
        ".config/bash/conf.d/broot.bash".text = ''
          eval "$(broot --print-shell-function bash)"
        '';
      });

    packages = [pkgs.broot];
  }
