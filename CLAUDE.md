# CLAUDE.md

## Philosophy

This is a personal NixOS desktop config. It is **simple, minimal, modern, bleeding edge, secure, and opinionated**.

- **Simple**: Reduce everything to its simplest form. Fewer layers, fewer abstractions, fewer moving parts. If something can be expressed more directly, it should be.
- **Minimal**: Every package, option, and line of config earns its place. No bloat, no defaults left unexamined. If something isn't actively used, it gets removed.
- **Modern**: Prefer modern replacements over legacy tools (eza over ls, bat over cat, helix over vim, nushell over bash). Track nixos-unstable. Use Nix flakes, not channels.
- **Bleeding edge**: Latest kernel, latest Plasma, latest packages. Stability comes from Nix's rollback, not from holding back versions.
- **Opinionated**: Strong choices, consistently applied. One way to do things, not every way. The config reflects personal taste, not broad compatibility.
- **Secure**: Prefer options that increase security and privacy. Minimize telemetry, reduce attack surface, and default to locked-down settings where practical.

## Taste

**Code style**: Concise and flat inside files, well-organized across the module structure. Prefer `let`/`inherit` over deep nesting. Keep files focused and short.

**When making changes**:
- Three similar lines are better than a premature abstraction.
- Don't add options, flags, or configurability unless asked. This config serves one machine and one user.
- Don't reorganize, refactor, or "improve" things that weren't asked about.
- Don't cargo-cult patterns from other NixOS configs. Understand the why before suggesting anything.
- Don't set options to their default values. If the default is already what we want, leave it out.
- Match existing conventions. Read surrounding code before writing new code.
- **Verify against real sources.** NixOS options, Home Manager options, and Nix syntax change frequently. Don't trust training data for anything non-trivial — check the actual nixpkgs source, option declarations, or official docs before suggesting module options or config patterns.
- **Push back like a domain expert.** If a request would compromise security, introduce unnecessary complexity, or go against well-established best practices, say so and defend the position. Don't just comply — give honest, informed resistance when it's warranted.

## Commands

```bash
nh os switch          # Rebuild system (aliased to `nr`)
nh os switch -u       # Rebuild with flake update (aliased to `nru`)
nix fmt .             # Format with Alejandra
statix check .        # Lint
statix fix .          # Auto-fix lint issues
```

## Key Patterns

**Theme system** (`lib/theme.nix`): A custom color palette available to all program configs via `specialArgs`. Use the `inherit (theme) colors;` pattern:

```nix
{ theme, ... }:
let
  inherit (theme) colors;
in {
  # colors.base00, colors.red, colors.text, colors.surface0, etc.
  # theme.diff for git colors, theme.ui for UI elements
}
```

**Adding packages**: Standalone packages go in `home.packages` in `users/jack/programs/programs.nix`. Managed programs get their own file in `users/jack/programs/` and an import in `programs.nix`.

**Secrets**: Managed via sops-nix. Edit with `sops secrets/secrets.yaml`.

## Structure

- `flake.nix` — single entry point, `mkHost` helper
- `hosts/nixos-orion/` — the one machine this manages
- `modules/` — system-level NixOS config (boot, desktop, networking, etc.)
- `users/jack/` — Home Manager config, shell, and per-program modules
- `lib/theme.nix` — color theme used across all program configs
- `secrets/` — sops-nix encrypted secrets
