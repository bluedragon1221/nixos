#!/usr/bin/env bash

arrow=""
text="#c6d0f5"
blue="#8aadf4"
green="#a6d189"
bg_dark="#1D1F32"
bg_lighter="#343950"

tset() {
  @tmux@/bin/tmux set -gq "$@"
}

# ensure status bar is enabled
tset status on

# Basic status bar colors
tset status-bg "$bg_dark"
tset status-attr none

# session
tset status-left-length 150
tset status-left "#[fg=$green,bg=$bg_lighter]   #S #[fg=$bg_lighter,bg=$bg_dark]$arrow"

# Window status format
tset window-status-format         "#[fg=$bg_dark,bg=$bg_lighter]$arrow#[fg=$text,bg=$bg_lighter] #I:#W #[fg=$bg_lighter,bg=$bg_dark]$arrow"
tset window-status-current-format "#[fg=$bg_dark,bg=$blue]$arrow#[fg=$bg_dark,bg=$blue,bold] #I:#W #[fg=$blue,bg=$bg_dark,nobold]$arrow"
tset window-status-separator ""

tset status-right " "
