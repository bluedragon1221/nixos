{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.cgit;
in
  lib.mkIf cfg.enable {
    hjem.users."git".files = {
      "git-shell-commands/set-description" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          repo="$1"
          desc="$2"
          base="/var/lib/cgit"
          repo_path="$base/$repo"

          test -d "$repo_path" || { echo "Repository does not exist"; exit 1; }

          # Prevent path traversal
          real=$(realpath "$repo_path")
          if [[ "$real" != "$base/"* ]]; then
              echo "Invalid path"
              exit 1
          fi

          echo "$desc" | head -n 1 > "$repo_path/description"

          echo "Description updated for '$repo'"
        '';
      };
      "git-shell-commands/create-repo" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          repo="$1"
          base="/var/lib/cgit"
          repo_path="$base/$repo"

          test -d "$repo_path" && { echo "Repository already exists."; exit 1; }

          git init --bare "$repo_path"
          echo "Repository '$repo' created"
        '';
      };
    };
  }
