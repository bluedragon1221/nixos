# Ganyupload - Agent Instructions

## Quick Context
- Simple Go file upload service using standard `net/http`.
- Single `main.go`, two Nix files (`default.nix`, `pkg.nix`), one README.
- Embedded README is served on GET /.
- Used as a NixOS module: `collinux.services.ganyupload` enables it, configures port and upload directory via systemd environment.

## How to Build and Test

### Build
```bash
nix build
```

Alternatively, from the repo root:
```bash
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Test
No dedicated test file. Verify locally by running with environment variables:
```bash
PORT=8080 UPLOAD_DIR=/tmp/upload go run main.go
```

Then test uploads:
```bash
curl -X PUT --data-binary @file.txt http://localhost:8080/file.txt
curl http://localhost:8080/  # Read embedded README
```

## Code Style

**Go:**
- Keep `main.go` clean; use `gofmt -w .`.
- Match existing error handling (early return, `log.Printf` for warnings, `log.Fatalf` for fatal errors).
- Path traversal prevention is critical; do not weaken `filepath.Clean` + `..` prefix checks.

**Nix:**
- Follow `/home/collin/nixos/AGENTS.md` conventions (2-space indent, common arg pattern, `lib.mkIf` for gating).
- `default.nix` imports `mkCaddyCfg.nix` to integrate with Caddy reverse proxy; do not remove that import.

## Key Implementation Notes

1. **Embedded README:** The README file is embedded at compile time using `//go:embed README`. If you update README, rebuild to reflect changes.
2. **Environment Variables:**
   - `UPLOAD_DIR`: Defaults to `.`, overridden by systemd service to `/media/ganyupload`.
   - `PORT`: Defaults to `8080`, set by systemd to the configured `cfg.port`.
3. **NixOS Integration:** The service runs as user/group `ganyupload` with home `/var/lib/ganyupload`. Ensure the service has write permission to `UPLOAD_DIR`.
4. **Caddy Integration:** `default.nix` imports `mkCaddyCfg.nix` to configure Caddy as a reverse proxy. Changes to hostname or port must be reflected in both Nix config and the Caddy rule.

## Common Tasks

- **Update Go code:** Edit `main.go`, test locally, then nix build to verify.
- **Change upload directory or port:** Update `default.nix` (systemd environment or `cfg.port`).
- **Update README:** Edit README file, then rebuild (`nix build`) so the embedded version updates.
- **Debug NixOS module:** Check `/etc/systemd/system/ganyupload.service` for actual service config after rebuild.

## Validation

After changes:
1. Run `nix build` from this directory or `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel` from repo root.
2. If applicable, test via `PORT=8080 UPLOAD_DIR=/tmp go run main.go`.
3. Verify no Nix lint issues (use repo-level `yo test` or `nix run nixpkgs#alejandra -- .` for formatting).
