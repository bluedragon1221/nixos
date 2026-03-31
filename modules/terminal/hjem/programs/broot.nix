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
    special_paths."~/.config".show = "always";

    verbs = [
      {
        name = "open-code";
        key = "enter";
        execution = "$EDITOR +{line} {file}";
        working_dir = "{root}";
        apply_to = "file";
        leave_broot = false;
      }
      {
        name = "lazygit";
        key = "ctrl-g";
        execution = "lazygit";
        working_dir = "{root}";
        apply_to = "any";
        leave_broot = false;
      }
      {
        name = "justfile";
        key = "ctrl-j";
        execution = "${pkgs.just}/bin/just --choose";
        working_dir = "{root}";
        apply_to = "any";
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
        name = "home";
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
