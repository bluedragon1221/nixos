{pkgs, ...}: {
  services.ollama.enable = true;
  # environment.systemPackages = [pkgs.mcphost];
}
