{
  cfgWrapper,
  inputs',
  pkgs,
  my-fish,
}:
cfgWrapper {
  pkg = inputs'.ghostty.packages."x86_64-linux".default;
  binName = "ghostty";
  extraFlags = [
    ''--command=${my-fish}/bin/fish''
    ''--window-decorations=false''
    ''--theme="catppuccin-macchiato"''
    ''--font-family="Iosevka Nerd Font"''
    ''--background-opacity=0.8''
    ''--keybind="ctrl+enter=new_split:right"''
    ''--keybind="ctrl+w=close_surface"''
  ];
}
