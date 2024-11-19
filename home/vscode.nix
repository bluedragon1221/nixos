{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      ms-vsliveshare.vsliveshare
    ];
    userSettings = {
      "workbench.colorTheme" = "Catppuccin Macchiato";
      "workbench.iconTheme" = "catppuccin-macchiato";
      "window.menuBarVisibility" = "toggle";
      "files.autoSave" = "afterDelay";
    };
  };
}
