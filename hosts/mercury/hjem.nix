{pkgs, ...}: {
  packages = with pkgs; [
    obsidian
    anki
    libreoffice-qt
    musescore

    prismlauncher
    mpv
    bluetuith

    opencode

    (pkgs.callPackage ../../pkgs/yo {})

    captive-browser # https://words.filippo.io/captive-browser
    (pkgs.makeDesktopItem {
      name = "captive-browser";
      desktopName = "Captive Browser";
      exec = "${pkgs.captive-browser}/bin/captive-browser";
      icon = "web-browser";
      terminal = false;
      categories = ["Application"];
    })

    (pkgs.writeShellScriptBin "battery.sh" ''
      energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
      energy_full=$(cat /sys/class/power_supply/BAT0/energy_full)
      percentage=$((energy_now * 100 / energy_full))
      printf "%.0f%%" "$percentage"
    '')
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
