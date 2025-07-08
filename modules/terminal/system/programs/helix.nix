{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.terminal.programs.helix;
  toml' = pkgs.formats.toml {};

  languages = toml'.generate "languages.toml" {
    language-server = {
      rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      nil.command = "${pkgs.nil}/bin/nil";
      superhtml = {
        command = "${pkgs.superhtml}/bin/superhtml";
        args = ["lsp"];
      };
      dhall-lsp-server.command = "${pkgs.dhall-lsp-server}/bin/dhall-lsp-server";
    };

    language = [
      {
        name = "nix";
        file-types = ["nix"];
        language-servers = ["nil"];
        indent = {
          tab-width = 2;
          unit = "  ";
        };
        formatter.command = "${pkgs.alejandra}/bin/alejandra";
        auto-format = true;
      }
      {
        name = "html";
        file-types = ["html"];
        language-servers = ["superhtml"];
        auto-format = true;
      }
    ];
  };

  customCatppuccinTheme = toml'.generate "catppuccin_mocha_transparent.toml" {
    inherits = "catppuccin_mocha";
    "ui.background" = {};
  };

  mkHelixConfig = {
    theme,
    hardMode ? false,
  }:
    toml'.generate "config.toml" {
      inherit theme;
      editor = {
        gutters = ["diff" "diagnostics" "line-numbers" "spacer" "spacer"];
        cursorline = true;
        color-modes = true;

        mouse = !hardMode;

        lsp.display-inlay-hints = true;

        statusline = {
          left = ["mode" "file-name" "spacer" "file-modification-indicator"];
          right = ["spinner" "spacer" "workspace-diagnostics" "file-type"];
          separator = "x";
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
      keys = {
        normal =
          {
            "C-space" = "expand_selection";
            "A-j" = ["extend_to_line_bounds" "delete_selection" "paste_after"];
            "A-k" = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before"];
            "X" = ["extend_line_up" "extend_to_line_bounds"];
            "C-left" = "goto_line_start";
            "C-right" = "goto_line_end";
            ";" = "flip_selections";
            "esc" = ["collapse_selection" "keep_primary_selection"];

            # I don't even use these anyway
            "pageup" = "no_op";
            "pagedown" = "no_op";
            "home" = "no_op";
            "end" = "no_op";
          }
          // (
            if hardMode
            then {
              "up" = "no_op";
              "down" = "no_op";
              "left" = "no_op";
              "right" = "no_op";
            }
            else {}
          );

        insert =
          {
            "pageup" = "no_op";
            "pagedown" = "no_op";
            "home" = "no_op";
            "end" = "no_op";
          }
          // (
            if hardMode
            then {
              "up" = "no_op";
              "down" = "no_op";
              "left" = "no_op";
              "right" = "no_op";
            }
            else {}
          );

        select = {
          "esc" = ["collapse_selection" "insert_mode"];
        };
      };
    };

  settings = mkHelixConfig {
    inherit (cfg) hardMode;
    theme =
      if cfg.theme == "catppuccin"
      then "catppuccin_mocha_transparent"
      else if cfg.theme == "adwaita"
      then "adwaita_dark"
      else "";
  };
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/helix/config.toml".source = settings;
        ".config/helix/languages.toml".source = languages;
        ".config/helix/themes/catppuccin_mocha_transparent.toml".source = customCatppuccinTheme;

        ".config/fish/conf.d/helix.fish".text = lib.mkIf config.collinux.terminal.shells.fish.enable ''
          set -gx EDITOR hx
        '';
      };

      packages = [
        pkgs.helix
      ];
    };
  }
