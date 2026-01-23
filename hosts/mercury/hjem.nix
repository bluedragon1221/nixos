{
  pkgs,
  inputs,
  ...
}: {
  packages = with pkgs; [
    # GUI apps
    tor-browser # don't ask
    obsidian
    kdePackages.kleopatra
    mpv
    musescore
    anki

    bluetuith

    kew # music player

    (prismlauncher.override {
      jdks = [pkgs.jdk17_headless];
    })

    vital

    captive-browser # https://words.filippo.io/captive-browser

    inputs.glide-browser.packages."x86_64-linux".default
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
