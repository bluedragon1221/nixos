{pkgs}: file: subs: let
  substitutions = pkgs.lib.pipe subs [
    (builtins.mapAttrs (k: v: "${k}=${v} "))
    builtins.attrValues
    (builtins.concatStringsSep "")
  ];
in
  pkgs.runCommand "substitution" {} ''
    touch $out
    ${substitutions} substituteAll ${file} $out
  ''
