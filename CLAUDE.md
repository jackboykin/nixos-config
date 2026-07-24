# CLAUDE.md

## Taste

**Code style**: Concise and flat inside files, well-organized across the module structure. Prefer `let`/`inherit` over deep nesting. Keep files focused and short.

**When making changes**:
- Don't cargo-cult patterns from other NixOS configs. Understand the why before suggesting anything.
- Don't set options to their default values. If the default is already what we want, leave it out.
- **Verify against real sources.** NixOS options, Home Manager options, and Nix syntax change frequently. Don't trust training data for anything non-trivial — check the actual nixpkgs source, option declarations, or official docs before suggesting module options or config patterns.

## Commands

```bash
nh os switch          # Rebuild system (aliased to `nr`)
nh os switch -u       # Rebuild with flake update (aliased to `nru`)
nh os boot            # Rebuild for next boot (aliased to `nb`)
nh os boot -u         # Rebuild for next boot with flake update (aliased to `nbu`)
nix fmt .             # Format with Alejandra
statix check .        # Lint
statix fix .          # Auto-fix lint issues
```

## Key Patterns

**Adding packages**: Standalone packages go in `home.packages` in `users/jack/programs/programs.nix`. Managed programs get their own file in `users/jack/programs/` and an import in `programs.nix`.

**Secrets**: Managed via sops-nix. Edit with `sops secrets/secrets.yaml`.

## Structure

- `flake.nix` — single entry point, `mkHost` helper
- `hosts/nixos-orion/` — the one machine this manages
- `modules/` — system-level NixOS config (boot, desktop, networking, etc.)
- `users/jack/` — Home Manager config, shell, and per-program modules
- `lib/theme.nix` — color theme used across all program configs
- `secrets/` — sops-nix encrypted secrets
