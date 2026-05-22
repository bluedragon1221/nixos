{
  pkgs,
  config,
  lib,
  tsunamiLib,
  std,
  ...
}: let
  inherit (tsunamiLib) scriptPath filePath;
  cfg = config.tsunami.sessionizer;
in {
  options = {
    tsunami.sessionizer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    tsunami.keys.leader = [
      {
        name = "Sessions+";
        key = "C-s";
        exec = "run-shell ${scriptPath "sessions-menu"}";
      }
    ];

    tsunami.scripts = {
      "sessionizer" =
        # bash
        ''
          [ -z "$1" ] && exit

          selected="$1"
          session_name="$(basename "$selected" | tr '.' '_')"

          # if the session doesn't exist, create it
          if ! tmux has-session -t "$session_name"; then
            tmux new-session -ds "$session_name" -c "$selected"
            tmux set-option -t "$session_name" @default-path "$selected"
          fi

          # switch to it
          tmux switch -t "$session_name"
        '';
      "launch-sessionizer" = ''${pkgs.broot}/bin/broot --only-folders --conf ${filePath "broot_sessionizer.toml"}'';
      "new-session" = ''tmux switch-client -t "$(tmux new-session -dP)"'';
      "sessions-menu" =
        # bash
        ''
          menu_items=(
            "Switch Session" s "run-shell '${scriptPath "minibuffer"} -d $HOME ${scriptPath "launch-sessionizer"}'"
            "New Unnamed Session" n "run-shell ${scriptPath "new-session"}"
          )

          # put tmux session names into a list
          mapfile -t sessions < <(tmux list-sessions -F "#{session_name}")

          # ...but limit at 9 sessions
          for i in "''\${!sessions[@]}"; do
            (( i >= 9 )) && break  # Stop after 9 sessions

            session="''\${sessions[$i]}"
            key=$((i + 1))  # 1-based key

            # and put those 9 in the list of menu items
            menu_items+=("$session" "$key" "switch-client -t $session")
          done

          # Display the menu
          ${scriptPath "menu"} -T "#[align=centre]Sessions" "''\${menu_items[@]}"
        '';
    };
    tsunami.files = {
      "broot_sessionizer.toml" = std.serde.toTOML {
        imports = ["~/.config/broot/conf.hjson"]; # inherit from user's config
        quit_on_cancel = true;
        verbs = [
          {
            invocation = "session";
            external = ''bash -c -- "${scriptPath "sessionizer"} '{file}'"'';
            key = "enter";
            apply_to = "directory";
            leave_broot = true;
          }
        ];
      };
    };
  };
}
