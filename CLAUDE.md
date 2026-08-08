# CLAUDE.md

## Taste

**Code style**: Concise and flat inside files, well-organized across the module structure. Prefer `let`/`inherit` over deep nesting. Keep files focused and short.

**When making changes**:
- Don't cargo-cult patterns from other NixOS configs. Understand the why before suggesting anything.
- Don't set options to their default values. If the default is already what we want, leave it out.
- **Verify against real sources.** NixOS options, Home Manager options, and Nix syntax change frequently. Don't trust training data for anything non-trivial — check the actual nixpkgs source, option declarations, or official docs before suggesting module options or config patterns.
- `flake.lock` churns from daily updates. Never revert it; fold it silently into whichever commit is at hand and otherwise ignore it unless the task is about inputs.
- Before committing, eval the flake (a build of the system closure counts) so `flake.lock` reflects the tree being committed, and always include any lock changes in the commit — a commit whose lock is stale or dangling isn't reproducible.

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

**Adding packages**: Standalone packages go in `users.users.${username}.packages` in `users/jack/programs/programs.nix`. Configured programs get their own file in `users/jack/programs/` and an import in `programs.nix`.

**User config files**: Dotfiles are declared with the `home.links` (path → store source, deployed as systemd-tmpfiles `L+` symlinks) and `home.dirs` options defined in `users/jack/home.nix`.

**Secrets**: Managed via sops-nix. Edit with `sops secrets/secrets.yaml`.

## Structure

- `flake.nix` — single entry point, `mkHost` helper
- `hosts/nixos-orion/` — the one machine this manages
- `modules/` — system-level NixOS config (boot, desktop, networking, etc.)
- `users/jack/` — user account, shell, and per-program modules
- `overlays/` — custom package sourcing and other bespoke configuration
- `lib/theme.nix` — color theme used across all program configs
- `secrets/` — sops-nix encrypted secrets
