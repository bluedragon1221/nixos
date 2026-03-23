# AGENTS.md

Guidance for agentic coding assistants working in this repository.

## 1) Project Snapshot

- Repo type: NixOS flake-based configuration repo.
- Core pattern: "homogenous modules" (shared `options.nix` + `nixos/default.nix` + `hjem/default.nix`).
- Main namespace for custom options: `collinux`.
- Hosts currently configured: `mercury`, `jupiter`, `ganymede`.
- Deployment helper: custom `yo` command (Ruby wrapper around `nix`/`nom`).

## 2) Rule Files Discovery

The following rule files were checked:

- `.cursor/rules/**`: not found
- `.cursorrules`: not found
- `.github/copilot-instructions.md`: not found

No Cursor/Copilot-specific rules are currently present in this repository.

## 3) Directory Landmarks

- `flake.nix`: top-level inputs/outputs, host definitions.
- `hosts/<hostname>/config.nix`: host-level declarative settings.
- `modules/`: feature modules (desktop, terminal, services, system, etc.).
- `lib/nix-furnace/mkSystem.nix`: module wiring and host assembly.
- `lib/lib.nix`: custom helper library (`my-lib`).
- `pkgs/yo/`: Ruby deploy/build helper package.
- `pkgs/yossh/`: Lua SSH helper package + lightweight tests.
- `docs/homogenous_modules.md`: architecture background.

## 4) Build / Check / Deploy Commands

Run from repo root: `/home/collin/nixos`.

### Core build commands

- Build current host and activate immediately:
  - `yo switch`
  - alias: `yo sw`
- Build current host and activate on next boot:
  - `yo boot`
- Build current host and test activation (non-persistent):
  - `yo test`
- Build a specific host configuration without switching:
  - `yo build <hostname>`
- Build current hostname (auto-detected):
  - `yo build`

### Direct nix builds

- Build one host toplevel derivation:
  - `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- Build generated docs package:
  - `nix build .#docs`
- Build default package output:
  - `nix build`

### Deploy commands

- Deploy via custom wrapper (see `pkgs/yo/default.nix` behavior):
  - `yo deploy <ssh-host-or-user@host>`
  - alias: `yo dep <ssh-host-or-user@host>`

Note: Some docs mention `yo deploy <hostname> <ssh-host>`; current code path derives hostname
from the SSH target argument.

## 5) Lint / Format / Validation

There is no single repo-wide lint target committed (no Makefile/justfile/pre-commit config found).

Use these practical checks:

- Nix syntax/eval sanity via host build:
  - `yo build <hostname>`
  - or `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- Option docs generation as additional eval coverage:
  - `nix build .#docs`
- Format Nix files with Alejandra (formatter used in editor config):
  - `nix run nixpkgs#alejandra -- .`

If you add new tool-specific linting, document the exact command in this file.

## 6) Test Commands (Including Single-Test Guidance)

### Repository-level tests

- No centralized automated test suite is wired at repo root.
- The most test-like validation is successful Nix evaluation/build per host.

### `pkgs/yossh` Lua tests

- Test file exists: `pkgs/yossh/tests/unit_tests.lua`.
- Run file directly:
  - `lua pkgs/yossh/tests/unit_tests.lua`

Important: current file defines tests and `main()` but does not call `main()` at EOF.
Running it as-is may not execute assertions unless the file is updated.

### Running a single test

There is no built-in single-test runner flag today.

Recommended workflow for single-test execution:

1. Temporarily edit `pkgs/yossh/tests/unit_tests.lua` so `main()` calls only one test function.
2. Run `lua pkgs/yossh/tests/unit_tests.lua`.
3. Revert the temporary test-selection edit before committing.

If you frequently need single-test runs, introduce a minimal CLI test selector and document it here.

## 7) Architecture Conventions You Must Preserve

- Keep host configs declarative attribute sets, not functions.
- Keep module option definitions in `options.nix` files.
- Keep NixOS implementation under `nixos/default.nix`.
- Keep hjem implementation under `hjem/default.nix`.
- Prefer adding features by extending existing module trees, not ad-hoc host logic.
- Use `my-lib` helpers when patterns already exist (`mkProgramOption`, `mkThemeOption`, etc.).
- Keep custom options under `collinux.*` to avoid collisions.

## 8) Code Style Guide

### General

- Match existing style in touched files; do not mass-reformat unrelated code.
- Keep diffs focused and minimal.
- Prefer explicit, descriptive names over abbreviations.
- Avoid adding comments unless logic is non-obvious.

### Nix style

- Indentation: 2 spaces; no tabs.
- Favor argument destructuring at top:
  - `{ pkgs, lib, config, ... }:` style.
- Common structure:
  - bind `cfg = config.collinux.<path>;` in `let`.
  - gate behavior with `lib.mkIf cfg.enable` where relevant.
- Prefer `inherit (lib) ...` for imported lib symbols.
- Keep `imports` lists clean and stable; one module per line.
- Use `mkOption`/`mkEnableOption` for options; include `description`, `type`, and sensible defaults.
- Use precise types (`types.port`, custom net types, `nullOr`, submodules) rather than loose strings.
- Prefer pure expressions and deterministic outputs.

### Import and dependency conventions

- Reuse local helpers from `my-lib` before adding new helper patterns.
- In modules, keep imports relative and predictable (`./foo.nix`, `./default.nix`).
- Avoid circular/implicit dependencies across module families.

### Naming conventions

- Nix option paths: lower camelCase segments under `collinux`.
- Files/modules: lowercase names, hyphenated when appropriate.
- Lua locals/functions: mostly snake_case in core library; preserve local file conventions.
- Ruby methods: snake_case; class/module names: CamelCase.

### Types and validation

- Add/keep explicit option types whenever possible.
- Use custom validators from `my-lib.netTypes` for network values.
- For structured config, prefer typed submodules over freeform attrs.

### Error handling

- Fail early with clear messages (`assertions`, explicit `error`/`raise`).
- In scripts/wrappers, check command success and raise on failure.
- Do not swallow errors from builds, copy, deploy, or switch operations.

### Secrets and security

- Never commit plaintext secrets.
- Use agenix-managed `.age` files and declared secret paths.
- Preserve service hardening settings unless there is a clear reason to change.

## 9) Agent Workflow Expectations

- Before changing behavior, read nearby module/options files to follow local patterns.
- Prefer validating with a targeted host build after Nix edits.
- If touching deployment logic, test with non-destructive build paths first.
- Keep commit scope tight: one logical change per commit.
- Update docs when command behavior or module patterns change.

## 10) Definition of Done (for automated agents)

- Code compiles/evaluates for affected host(s) via `yo build <hostname>` or equivalent.
- New/changed options are typed and documented by structure.
- Formatting is consistent with current repository conventions.
- No plaintext secrets introduced.
- Any new commands, checks, or test entrypoints are reflected in this `AGENTS.md`.
