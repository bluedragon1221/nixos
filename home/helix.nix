{ pkgs, lib, ... }: {
  catppuccin.helix.enable = true;
  programs.helix = {
    enable = true;
    defaultEditor = true;

    # lsp servers
    extraPackages = with pkgs; [
      nil
      rust-analyzer
      lua-language-server
      vscode-langservers-extracted
      python312Packages.python-lsp-server
      python312Packages.python-lsp-ruff
      python312Packages.pylsp-rope
      alejandra
      superhtml
      emmet-language-server
    ];

    languages = {
      language-server."emmet-language-server" = {
        command = "emmet-language-server";
        args = ["--stdio"];
      };

      language = [
        {
          name = "nix";
          file-types = ["nix"];
          language-servers = ["nil"];
          indent = {tab-width = 2; unit = "  ";};
          formatter = {command = "alejandra";};
          auto-format = true;
        }
        {
          name = "html";
          file-types = ["html"];
          language-servers = ["emmet-language-server" "superhtml"];
          auto-format = true;
        }
      ];
    };

    settings = lib.mkMerge [
      {
        editor = {
          gutters = ["diff" "diagnostics" "line-numbers" "spacer" "spacer"];
          cursorline = true;
          color-modes = true;

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
          normal = {
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
          };

          insert = {
            "pageup" = "no_op";
            "pagedown" = "no_op";
            "home" = "no_op";
            "end" = "no_op";
          };

          select = {
            "esc" = ["collapse_selection" "insert_mode"];
          };
        };
      }
      {
          # Hard mode activated...
          editor.mouse = false;
          keys.normal = {
            "up" = "no_op";
            "down" = "no_op";
            "left" = "no_op";
            "right" = "no_op";
          };
          keys.insert = {
            "up" = "no_op";
            "down" = "no_op";
            "left" = "no_op";
            "right" = "no_op";
          };
        }
      ];
    };
}
