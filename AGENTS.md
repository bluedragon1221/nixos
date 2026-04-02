# AGENTS.md

Guidance for coding agents working in this repository.

## 1) Repository Purpose
- NixOS flake repo with host configs, reusable modules, and local packages.
- Most edits happen in `hosts/`, `modules/`, `lib/`, and `pkgs/`.
- Includes a standalone Go project at `pkgs/jta/`.
- Make focused changes; avoid unrelated refactors.

## 2) AI Rule Files (Cursor/Copilot)
- `.cursor/rules/`: not found.
- `.cursorrules`: not found.
- `.github/copilot-instructions.md`: not found.
- There are no repository-specific Cursor/Copilot instruction files to apply.

## 3) Key Paths
- `flake.nix`: flake inputs/outputs and host definitions.
- `hosts/<hostname>/config.nix`: host-level entrypoints.
- `modules/`: homogenous module tree.
- `lib/nix-furnace/mkSystem.nix`: system composition.
- `lib/lib.nix`: shared helpers (`my-lib`).
- `pkgs/yo/`: Ruby deployment/build helper.
- `pkgs/yossh/`: Lua SSH tooling and tests.
- `pkgs/jta/`: Go module.
- `justfile`: command shortcuts.

## 4) Build Commands
Run from `/home/collin/nixos` unless noted.

NixOS commands:
- `yo build`
- `yo build <hostname>`
- `yo switch` or `yo sw`
- `yo boot`
- `yo test`
- `yo deploy <ssh-target>` or `yo dep <ssh-target>`

Direct Nix commands:
- `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- `nix build .#docs`
- `nix build`

Just shortcuts:
- `just build`
- `just switch`
- `just deploy`

Go project (`pkgs/jta`):
- `go build ./...`
- `go run .`

## 5) Lint and Formatting
Nix:
- `nix run nixpkgs#alejandra -- .`
- Prefer formatting only touched files.

Go (`pkgs/jta`):
- `gofmt -w .`
- `go vet ./...`

Validation defaults:
- After Nix changes, run a host build.
- After Go changes, run build and tests.

## 6) Test Commands
Repository-wide:
- No single root test harness is configured.
- Nix host builds are primary verification.

Nix checks:
- `yo build <hostname>`
- `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`

Go tests (`pkgs/jta`):
- Run all tests: `go test ./...`
- Run single test name: `go test ./... -run '^TestName$'`
- Run single test in current package: `go test . -run '^TestName$'`

Lua tests (`pkgs/yossh`):
- Run all defined tests: `lua pkgs/yossh/tests/unit_tests.lua`
- Current single-test method is manual (temporarily call one test in `main()`).

## 7) Architectural Conventions
- Preserve homogenous module layout:
  - `options.nix` for option definitions.
  - `nixos/default.nix` for NixOS implementation.
  - `hjem/default.nix` for hjem implementation.
- Keep custom options under `collinux.*`.
- Keep host configs declarative.
- Reuse existing helper patterns before creating new abstractions.

## 8) Code Style
General:
- Match style of the touched file.
- Keep diffs minimal and intentional.
- Prefer explicit naming over abbreviations.
- Add comments only for non-obvious logic.

Nix style:
- 2-space indentation; no tabs.
- Common arg pattern: `{ lib, config, pkgs, ... }:`.
- Use `cfg = config.collinux.<path>;` when it improves clarity.
- Use `lib.mkIf` for option-gated config.
- Prefer typed options (`types.port`, `types.nullOr`, submodules).
- Keep imports stable and readable (usually one per line).
- Use `inherit (lib) ...` where idiomatic.

Imports/dependencies:
- Prefer relative imports in module trees (`./foo.nix`).
- Avoid circular dependencies.
- Reuse `my-lib` helpers from `lib/lib.nix` when possible.

Go style (`pkgs/jta`):
- Keep code gofmt-clean.
- Preserve gofmt import ordering/grouping.
- Prefer early error returns.
- Use standard `net/http` helpers consistently.

Ruby style (`pkgs/yo`):
- snake_case for methods/locals; CamelCase for classes/modules.
- Validate CLI args and fail fast (`abort` with clear message).
- Do not hide command failures.

Lua style (`pkgs/yossh`, `pkgs/util`):
- Follow local naming conventions (mostly snake_case).
- Keep helpers small and composable.
- Raise clear errors instead of ambiguous nil behavior.

## 9) Types, Naming, and Error Handling
- Use explicit Nix option types whenever practical.
- Option naming: lower camelCase segments under `collinux`.
- File naming: lowercase; hyphenate when local pattern uses it.
- Fail early with actionable error messages.
- Do not swallow build/deploy/switch failures.

## 10) Secrets and Safety
- Never commit plaintext secrets.
- Preserve agenix and `.age` workflows.
- Treat `hosts/*/secrets/*` and `*.age` as sensitive.
- Do not weaken security defaults without explicit intent.

## 11) Workflow for Agents
- Read adjacent files before editing.
- Follow established patterns first.
- Validate the smallest meaningful scope.
- Update docs when command behavior changes.

## 12) Definition of Done
- Affected targets build/evaluate successfully.
- Formatting and style are consistent.
- New options are typed appropriately.
- No plaintext secrets introduced.
- This AGENTS guide remains accurate.
