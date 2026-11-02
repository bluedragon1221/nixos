{inputs, ...}: {
  imports = [
    ./github_ssh.nix

    inputs.noshell.nixosModules.default
  ];

  programs.command-not-found.enable = false; # broken without nix-channels
  programs.noshell.enable = true;

  environment.etc = {
    "bashrc.local".text = ''
      if [ -s "''${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc" ]; then
        . "''${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc"
      fi
    '';
  };
}
