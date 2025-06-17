# Terminal Workflow

Each project that I'm working on has its own tmux session.
Using a variation of ThePrimeagen's tmux-sessionizer, I can switch to any project with `C-f`.

Within a session, I use multiple panes and windows to organize my commands.
To open an existing file, get to a shell (either a new window, new pane, or freeing up the current pane), and hit `br` to launch broot.
From there, I can fuzzy find to the file, and hit `enter` to open it in Helix.
