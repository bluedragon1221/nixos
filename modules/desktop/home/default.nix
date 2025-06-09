let
  findPrograms =
    builtins.attrValues
    (builtins.mapAttrs
      (file: type: ./programs/${file})
      (builtins.readDir ./programs));
in {
  imports =
    [
      ./environments/gnome
      ./gtk
    ]
    ++ findPrograms;
}
