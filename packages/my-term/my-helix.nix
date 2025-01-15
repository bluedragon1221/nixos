{
  cfgWrapper,
  pkgs,
}: let
  settings = (pkgs.formats.toml {}).generate "config.toml" {
    theme = "catppuccin_macchiato";
    editor = {
      gutters = ["diff" "diagnostics" "line-numbers" "spacer" "spacer"];
      cursorline = true;
      color-modes = true;

      lsp.display-inlay-hints = true;

      statusline = {
        left = ["mode" "file-name" "spacer" "file-modification-indicator"];
        right = ["spinner" "spacer" "workspace-diagnostics" "file-type"];
      };

      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
    };
    keys = {
      normal = {
        "C-space" = "expand_selection";
        "A-down" = ["extend_to_line_bounds" "delete_selection" "paste_after"];
        "A-up" = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before"];
        "X" = ["extend_line_up" "extend_to_line_bounds"];
        "C-left" = "goto_line_start";
        "C-right" = "goto_line_end";
        ";" = "flip_selections";
        "esc" = ["collapse_selection" "keep_primary_selection"];
      };

      select = {
        "esc" = ["collapse_selection" "insert_mode"];
      };
    };
  };

  extraPkgs = with pkgs; [
    nil
    rust-analyzer
    lua-language-server
    vscode-langservers-extracted
    python312Packages.python-lsp-server
    python312Packages.python-lsp-ruff
    python312Packages.pylsp-rope

    # not supported (must be added in project-specific .helix/languages.toml)
    alejandra
    emmet-language-server
    superhtml
  ];
in
  cfgWrapper {
    pkg = pkgs.helix;
    binName = "hx";
    inherit extraPkgs;
    extraFlags = ["-c ${settings}"];
    hidePkgs = true;
  }
