# CLAUDE.md

This file provides guidance to AI assistants (Claude, Gemini, etc.) and collaborators when working with this NixOS configuration repository.

## Repository Overview

This is a modular NixOS configuration using Nix Flakes. It manages a single desktop workstation (`nixos-orion`) with Home Manager for user-level configuration.

## Core Commands

### System Rebuild
```bash
# Rebuild NixOS system (via nh helper)
nh os switch

# Rebuild with flake update
nh os switch -u

# Standard rebuild (alternative)
sudo nixos-rebuild switch --flake ~/nixos-config
```

### Formatting
```bash
# Format all Nix files with Alejandra
nix fmt .
```

### Linting
```bash
# Check for common Nix anti-patterns and style issues
statix check .

# Auto-fix issues where possible
statix fix .
```

### Flake Operations
```bash
# Update flake.lock
nix flake update

# Check flake for errors
nix flake check
```

## Architecture Overview

### Directory Structure
```
nixos-config/
├── flake.nix           # Flake definition with mkHost helper
├── flake.lock          # Pinned dependencies
├── install.sh          # Automated installation script
├── hosts/              # Host-specific configurations
│   └── nixos-orion/    # Primary desktop workstation
│       ├── host.nix
│       └── hardware-configuration.nix
├── lib/                # Shared utilities
│   └── theme.nix       # Custom color theme with mixing functions
├── modules/            # System-level NixOS modules
│   ├── modules.nix     # Entry point for all modules
│   ├── boot.nix        # Kernel, Lanzaboote secure boot
│   ├── desktop.nix     # Plasma 6, SDDM, PipeWire, fonts
│   ├── hardware.nix    # Hardware-specific settings
│   ├── locale.nix      # Timezone, locale
│   ├── networking.nix  # NetworkManager, Tailscale, dnscrypt-proxy
│   ├── nix.nix         # Nix settings, caches, unfree
│   ├── secrets.nix     # sops-nix configuration
│   ├── system-packages.nix
│   └── users.nix       # System users
├── secrets/            # Encrypted secrets
│   ├── .sops.yaml      # sops configuration
│   └── secrets.yaml    # Encrypted data
└── users/              # Home Manager configurations
    └── jack/
        ├── user.nix    # Main user config entry point
        ├── shell.nix   # Shell aliases and PATH
        └── programs/
            ├── programs.nix    # Imports managed programs + standalone packages
            ├── bat.nix
            ├── btop.nix
            ├── direnv.nix
            ├── eza.nix
            ├── firefox.nix
            ├── fzf.nix
            ├── git.nix
            ├── konsole.nix
            ├── lazygit.nix
            ├── llm-agents.nix
            ├── mpv.nix
            ├── helix.nix
            ├── nushell.nix
            ├── rust.nix
            ├── tmux.nix
            └── zoxide.nix
```

### Key Components

**Flake Inputs:**
- `nixpkgs` (nixos-unstable)
- `home-manager`
- `lanzaboote` (secure boot)
- `rust-overlay`
- `nur`
- `sops-nix` (secrets management)
- `llm-agents` (LLM coding agents from numtide)

**Desktop Environment:**
- KDE Plasma 6 with SDDM
- PipeWire audio (low-latency)
- Secure boot via Lanzaboote

**Networking Stack:**
- NetworkManager with systemd-resolved
- dnscrypt-proxy (Cloudflare + Quad9)
- Tailscale mesh VPN
- Wake-on-LAN enabled

## Theme System

Located in `lib/theme.nix`, provides:
- Base16-style color palette ("Bellatrix" v4 dark theme)
- `mixColors` function for color blending
- `hexToRgb` / `rgbToHex` conversions
- Semantic and Functional UI roles:
    - `text`, `subtext0`, `subtext1`
    - `surface0`, `surface1`, `surface2`
    - `overlay0`, `overlay1`, `overlay2`
    - `error`, `warning`, `info`, `hint`
    - `gitAdded`, `gitModified`, `gitDeleted`
- Specialized color sets:
    - `theme.diff` for git tools (hunkHeader, plus, minus, etc.)
    - `theme.ui` for common UI elements (selection, cursor, activeBorder)

**Usage in program configs:**
```nix
{ theme, ... }:
let
  inherit (theme) colors;
in {
  # Access colors.base00, colors.red, colors.text, etc.
}
```

## Managed Programs

Programs in `users/jack/programs/` have declarative configs:

| Program | Purpose |
|---------|---------|
| `helix.nix` | Primary editor with LSP, Treesitter |
| `nushell.nix` | Default shell |
| `git.nix` | Git with delta pager |
| `lazygit.nix` | Terminal Git UI |
| `tmux.nix` | Terminal multiplexer |
| `firefox.nix` | Browser with hardened settings |
| `bat.nix` | Cat replacement with themes |
| `btop.nix` | System monitor |
| `fzf.nix` | Fuzzy finder |
| `eza.nix` | Modern ls |
| `zoxide.nix` | Smart cd |
| `direnv.nix` | Per-directory environments |
| `mpv.nix` | Media player |
| `konsole.nix` | KDE terminal |
| `rust.nix` | Rust toolchain (stable + rust-analyzer) |
| `llm-agents.nix` | LLM coding agents (claude-code, codex, pi) |

## Shell Aliases

Defined in `users/jack/shell.nix`:
```bash
q       → exit
nr      → nh os switch
nru     → nh os switch -u
cat     → bat
lz      → lazygit
g       → git
ga      → git add -A
gc      → git commit -m "..."
ls      → eza --icons --group-directories-first
l       → eza (detailed list with git info)
lr      → eza (recursive list)
tree    → eza --tree
treea   → eza --tree (all files)
grep    → rg
```

## Adding New Hosts

Edit `flake.nix`:
```nix
nixosConfigurations = {
  new-host = mkHost {
    hostname = "new-host";
    username = "jack";
    extraModules = [ ./hosts/new-host/extra.nix ];
  };
};
```

## Adding New Programs

1. **Standalone package**: Add to `home.packages` in `users/jack/programs/programs.nix`
2. **Managed program**: Create `users/jack/programs/program.nix` and import in `programs.nix`

## Secrets Management

Managed via `sops-nix`:
- **Secrets file**: `secrets/secrets.yaml`
- **Key location**: `/var/lib/sops-nix/key.txt` (age key)
- **Configuration**: `modules/secrets.nix` and `.sops.yaml`

To edit secrets:
```bash
sops secrets/secrets.yaml
```

## Installation

An automated installation script is provided for fresh installs from a NixOS live ISO.

```bash
# Run from a NixOS live ISO
sudo bash install.sh
```

The script handles:
1. Partitioning and formatting (GPT, EFI, Ext4)
2. Cloning this repository
3. Generating hardware configuration
4. Creating initial Lanzaboote keys
5. Setting up the SOPS age key (searches for `keys.txt` on a Ventoy USB)
6. Installing NixOS

## Important Notes

- State version: `25.11`
- Kernel: Latest Linux with AMD pstate
- Secure boot keys stored at `/var/lib/sbctl` (Lanzaboote v1.0.0 standard location)
- Secrets: System age key must be present at `/var/lib/sops-nix/key.txt`
- All program configs can access `theme` via `specialArgs`
- Use `inherit (theme) colors;` pattern in managed programs
- **Default shell: nushell**

## Development Workflow

1. Edit configuration files
2. Run `statix check .` to lint for issues
3. Run `nix fmt .` to format
4. Run `nr` (alias for `nh os switch`) to rebuild
5. Test changes

## Troubleshooting

**Build errors:**
```bash
# Verbose rebuild for debugging
sudo nixos-rebuild switch --flake ~/nixos-config --show-trace
```

**Rollback:**
```bash
sudo nixos-rebuild switch --rollback
```
