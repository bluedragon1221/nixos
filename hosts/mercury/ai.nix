{pkgs, ...}: {
  services.ollama.enable = true;
  # environment.systemPackages = [pkgs.mcphost];

  hjem.users."collin".files.".config/fish/conf.d/ollama.fish".text = ''
    set -gx OLLAMA_NOHISTORY 1
  '';
}
