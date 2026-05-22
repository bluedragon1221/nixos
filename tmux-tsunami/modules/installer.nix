{pkgs, ...}: let
  tsunamiLib = {
    scriptPath = f: "$HOME/.config/tmux/scripts/${f}.sh";
    filePath = f: "$HOME/.config/tmux/files/${f}";
  };
  config = pkgs.lib.evalModules {
    modules =
      [
        {_module.args = {inherit pkgs tsunamiLib;};}
      ]
      ++ (pkgs.lib.filesystem.listFilesRecursive ./common);
  };

  moduleConfig = pkgs.writeText "tsunami-installer-config.json" (builtins.toJSON {
    inherit (config.config.tsunami) scripts files confs;
  });
in {
  mkInstaller =
    pkgs.runCommand "tsunami-installer" {
      buildInputs = [pkgs.jq];
    } ''
      mkdir -p $out
      {
        cat ${moduleConfig} | jq -r '
          (.scripts | to_entries[] | "cat <<\"EOF\" > $HOME/.config/tmux/scripts/\(.key).sh\n\(.value)\nEOF\n"),
          (.files   | to_entries[] | "cat <<\"EOF\" > $HOME/.config/tmux/files/\(.key)\n\(.value)\nEOF\n"),
          (.confs   | to_entries[] | "cat <<\"EOF\" > $HOME/.config/tmux/conf.d/\(.key).conf\n\(.value)\nEOF\n")
        '
        printf '
          cat <<EOF > $HOME/.config/tmux/tmux.conf
          run-shell "find $out/conf.d -print0 | xargs -0 -n1 tmux source-file"
          EOF
        '
      } > $out/tsunami-installer

      chmod +x $out/tsunami-installer
    '';
}
