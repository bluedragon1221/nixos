## Pieces:
sessionizer
- leaderkey keybinding C-p+
- script launch-sessionizer
- script clean-sessions
- script new-session
- script projects-menu
- extrafile broot_sessionizer

```nix
{pkgs, tsunamiLib, ...}: let
  inherit (tsunamiLib) scriptPath filePath;
in {
  tsunami.keys.leader = [{
    name = "Projects+";
    key = "C-p";
    exec = "run-shell ${scriptPath "projects-menu"}";
  }];

  tsunami.scripts = {
    "launch-sessionizer" = ''${pkgs.broot}/bin/broot --conf ${filePath "broot_sessionizer.toml"}'';
    "clean-sessions" = ''...'';
    "new-session" = ''...'';
  };
  tsunami.files = {
    "broot_sessionizer.toml" = (pkgs.formats.toml {}).generate "file.toml" {
      ...
    };
  };
}
```

find-file
- leaderkey keybinding C-f
- script find-file
- extrafile broot_find_file
fzf-exec
- keybinding M-x
- script tmux-doc
- script fzf-exec
search-buffer
- leaderkey keybinding C-/
- script search-buffer
find-window
- leaderkey keybinding C-w
- script find-buffer
leader-key
- keybinding C-x
- script leader-menu
bar
- script bar
- script battery
main config
- script minibuffer
- script split
- 
