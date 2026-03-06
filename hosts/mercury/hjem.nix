{pkgs, ...}: {
  packages = with pkgs; [
    obsidian
    anki
    libreoffice-qt

    kdePackages.kleopatra
    prismlauncher
    mpv

    claude-code

    lagrange

    musescore
    vital

    bluetuith
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

  files.".claude/settings.json".text = builtins.toJSON {
    env = {
      ANTHROPIC_BASE_URL = "http://localhost:4141";
      ANTHROPIC_AUTH_TOKEN = "sk-dummy";
      ANTHROPIC_MODEL = "claude-sonnet-4.5";
      ANTHROPIC_DEFAULT_HAIKU_MODEL = "gpt-5-mini";
      DISABLE_NON_ESSENTIAL_MODEL_CALLS = "1";
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
      CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
    };
  };
}
