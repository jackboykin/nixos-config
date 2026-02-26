# CLAUDE.md

## Philosophy

This is a personal NixOS desktop config. It is **minimal, modern, bleeding edge, and opinionated**.

- **Minimal**: Every package, option, and line of config earns its place. No bloat, no defaults left unexamined. If something isn't actively used, it gets removed.
- **Modern**: Prefer modern replacements over legacy tools (eza over ls, bat over cat, helix over vim, nushell over bash). Track nixos-unstable. Use Nix flakes, not channels.
- **Bleeding edge**: Latest kernel, latest Plasma, latest packages. Stability comes from Nix's rollback, not from holding back versions.
- **Opinionated**: Strong choices, consistently applied. One way to do things, not every way. The config reflects personal taste, not broad compatibility.

## Direction

This config is **mature and in refinement mode**. The architecture is settled. Changes should be polishing, tuning, and maintaining — not rearchitecting. Don't add complexity in pursuit of generality that isn't needed.

## Taste

**Code style**: Concise and flat inside files, well-organized across the module structure. Prefer `let`/`inherit` over deep nesting. Keep files focused and short. No clever abstractions — just clear, direct Nix.

**When making changes**:
- Do the simplest thing that works. Three similar lines are better than a premature abstraction.
- Don't add options, flags, or configurability unless asked. This config serves one machine and one user.
- Don't reorganize, refactor, or "improve" things that weren't asked about.
- Don't cargo-cult patterns from other NixOS configs. Understand the why before suggesting anything.
- Match existing conventions. Read surrounding code before writing new code.
- **Verify against real sources.** NixOS options, Home Manager options, and Nix syntax change frequently. Don't trust training data for anything non-trivial — check the actual nixpkgs source, option declarations, or official docs before suggesting module options or config patterns.

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
