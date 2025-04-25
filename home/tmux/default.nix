{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file ${./tmux.conf}
      run-shell ${./bar.sh}
    '';
  };
}
