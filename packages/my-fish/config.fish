# ugly greeting gone
set fish_greeting

# prompt
starship init fish | source
fzf --fish | source

# aliases
abbr -a nh nh os switch
abbr -a ga --set-cursor "git add %"
abbr -a gc --set-cursor "git commit -m '%'"
abbr -a gp "git push"

alias ls '${pkgs.eza}/bin/eza -A -w 80 --group-directories-first'
alias tree '${pkgs.eza}/bin/eza -T'

alias cat 'bat'
alias icat 'kitten icat'

# environment variables
set -x EDITOR hx
set -x VISUAL hx

set -x XDG_DATA_HOME ~/.local/share
set -x XDG_CONFIG_HOME ~/.config
set -x XDG_STATE_HOME ~/.local/state
set -x XDG_CACHE_HOME ~/.cache

set -x CARGO_HOME $XDG_DATA_HOME/cargo
set -x PYTHON_HISTORY $XDG_DATA_HOME/python/python_history
set -x GOPATH $XDG_DATA_HOME/go
set -x HISTFILE $XDG_DATA_HOME/bash/history # for children bash sessions

