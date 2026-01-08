let
  # host keys
  mercury = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQtMAgPdWwrOzlZT/lEIRQZ+ajhafG9AEJCrF2/bsmN";
  jupiter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPB7feUHl5qoD5zF9AMOV2meViA+wZYdVvbVjPkggZf8";
  ganymede = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlr+53UmlGVP1blkdNl6NFqn1w2umFJyjH1EVUPKIy9";
in {
  "caddy-env.age".publicKeys = [ganymede];
  "williams-psk.age".publicKeys = [ganymede];
  "github-ssh-key.age".publicKeys = [mercury jupiter];
}
