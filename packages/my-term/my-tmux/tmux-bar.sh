#!/usr/bin/env bash

arrow=""
text="#c6d0f5"
blue="#b7bdf8"
green="#a6d189"
bg_dark="#1d1f32"
bg_lighter="#343950"

tset() {
  @tmux@/bin/tmux set -gq "$@"
}

# ensure status bar is enabled
tset status on

# Basic status bar colors
tset status-bg "$bg_dark"

# current session
tset status-left "#[fg=$green,bg=$bg_lighter]   #S #[fg=$bg_lighter,bg=$bg_dark]$arrow"

# window list
tset window-status-format         "#[fg=$bg_dark,bg=$bg_lighter]$arrow#[fg=$text,bg=$bg_lighter] #I:#W #[fg=$bg_lighter,bg=$bg_dark]$arrow"
tset window-status-current-format "#[fg=$bg_dark,bg=$blue]$arrow#[fg=$bg_dark,bg=$blue,bold] #I:#W #[fg=$blue,bg=$bg_dark,nobold]$arrow"
tset window-status-separator      ""

tset status-right " "
