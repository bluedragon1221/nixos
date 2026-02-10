{
  pkgs,
  inputs,
  ...
}: let
  captiveBrowserDesktop = pkgs.makeDesktopItem {
    name = "captive-browser";
    desktopName = "Captive Browser";
    exec = "${pkgs.captive-browser}/bin/captive-browser";
    icon = "web-browser";
    terminal = false;
    categories = ["Application"];
  };
in {
  packages = with pkgs; [
    tor-browser # don't ask

    obsidian
    kdePackages.kleopatra
    anki
    musescore
    libreoffice-qt

    mpv
    bluetuith

    kew # music player
    irssi

    prismlauncher

    vital

    captive-browser # https://words.filippo.io/captive-browser
    captiveBrowserDesktop
    inputs.glide-browser.packages."x86_64-linux".default

    (pkgs.callPackage ../../pkgs/yoshi.nix {inherit inputs;})
    (pkgs.callPackage ../../pkgs/yo.nix {inherit inputs;})
  ];

  files.".config/captive-browser.toml".text = ''
    browser = """
      ${pkgs.ungoogled-chromium}/bin/chromium \
        --proxy-server="socks5://$PROXY" \
        --no-default-browser-check \
        --no-first-run \
        --no-managed-user-acknowledgment-check \
        --app=http://neverssl.com
    """

    dhcp-dns = "echo 10.0.5.82"

    socks5-addr = "localhost:1666"
  '';
}
