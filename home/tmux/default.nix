{
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    escapeTime = 0; # fix slow escape in editor
    extraConfig = ''
      source-file ${./tmux.conf}
      run-shell ${./bar.sh}
    '';
  };
}
