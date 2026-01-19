#!/usr/bin/env bash
#
# NixOS Installation Script
# Automated reinstall from a live NixOS ISO
#
# Usage: bash <(curl -sL https://gist.githubusercontent.com/jackboykin/nixos-config/install.sh)
#

set -euo pipefail

# Configuration
REPO_URL="https://github.com/jackboykin/nixos-config"
FLAKE_HOST="nixos-orion"
USERNAME="jack"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }

# -----------------------------------------------------------------------------
# Prerequisites Check
# -----------------------------------------------------------------------------
check_prerequisites() {
    info "Checking prerequisites..."

    # Must be root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo bash install.sh"
    fi
    success "Running as root"

    # Check if on NixOS live ISO (check for /etc/NIXOS and installer environment)
    if [[ ! -f /etc/NIXOS ]]; then
        error "This script must be run from a NixOS live ISO"
    fi
    success "Running on NixOS"

    # Check for required tools
    for cmd in parted mkfs.fat mkfs.ext4 git nixos-install; do
        if ! command -v "$cmd" &>/dev/null; then
            error "Required command not found: $cmd"
        fi
    done
    success "All required tools available"

    # Check network connectivity
    if ! ping -c 1 github.com &>/dev/null; then
        warn "No network connection detected. Please configure networking first."
        warn "Use: nmtui, or for wifi: wpa_supplicant"
        error "Network required for installation"
    fi
    success "Network connectivity confirmed"
}

# -----------------------------------------------------------------------------
# Disk Selection
# -----------------------------------------------------------------------------
select_disk() {
    info "Available block devices:"
    echo ""
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "disk|NAME"
    echo ""

    read -rp "Enter target disk (e.g., /dev/nvme0n1 or /dev/sda): " TARGET_DISK

    # Validate disk exists
    if [[ ! -b "$TARGET_DISK" ]]; then
        error "Disk not found: $TARGET_DISK"
    fi

    # Ensure it's a whole disk, not a partition
    if [[ "$TARGET_DISK" =~ [0-9]$ ]] && [[ ! "$TARGET_DISK" =~ nvme.*n[0-9]$ ]]; then
        error "Please specify the whole disk, not a partition"
    fi

    echo ""
    warn "WARNING: This will DESTROY ALL DATA on $TARGET_DISK"
    warn "The following partitions will be wiped:"
    lsblk "$TARGET_DISK" -o NAME,SIZE,FSTYPE,MOUNTPOINT
    echo ""

    read -rp "Type 'yes' to confirm destruction of $TARGET_DISK: " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        error "Aborted by user"
    fi
}

# -----------------------------------------------------------------------------
# Partitioning
# -----------------------------------------------------------------------------
partition_disk() {
    info "Partitioning $TARGET_DISK..."

    # Unmount any existing mounts from this disk
    umount -R /mnt 2>/dev/null || true
    for part in "${TARGET_DISK}"*; do
        umount "$part" 2>/dev/null || true
    done

    # Wipe existing partition table
    wipefs -af "$TARGET_DISK"

    # Create GPT partition table
    parted -s "$TARGET_DISK" mklabel gpt

    # Create EFI partition (512MB)
    parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 513MiB
    parted -s "$TARGET_DISK" set 1 esp on

    # Create root partition (remaining space)
    parted -s "$TARGET_DISK" mkpart root ext4 513MiB 100%

    # Wait for kernel to recognize new partitions
    sleep 2
    partprobe "$TARGET_DISK"
    sleep 1

    success "Partitioning complete"
}

# -----------------------------------------------------------------------------
# Determine partition names
# -----------------------------------------------------------------------------
get_partition_names() {
    # Handle different naming conventions (nvme vs sata)
    if [[ "$TARGET_DISK" =~ nvme ]]; then
        EFI_PART="${TARGET_DISK}p1"
        ROOT_PART="${TARGET_DISK}p2"
    else
        EFI_PART="${TARGET_DISK}1"
        ROOT_PART="${TARGET_DISK}2"
    fi

    # Verify partitions exist
    if [[ ! -b "$EFI_PART" ]] || [[ ! -b "$ROOT_PART" ]]; then
        error "Partitions not found. Expected: $EFI_PART and $ROOT_PART"
    fi
}

# -----------------------------------------------------------------------------
# Formatting
# -----------------------------------------------------------------------------
format_partitions() {
    info "Formatting partitions..."

    get_partition_names

    # Format EFI partition
    mkfs.fat -F 32 -n BOOT "$EFI_PART"
    success "Formatted EFI partition: $EFI_PART"

    # Format root partition
    mkfs.ext4 -L nixos -F "$ROOT_PART"
    success "Formatted root partition: $ROOT_PART"
}

# -----------------------------------------------------------------------------
# Mounting
# -----------------------------------------------------------------------------
mount_partitions() {
    info "Mounting partitions..."

    # Ensure partition names are set
    get_partition_names

    # Wait for udev to process the new filesystems
    udevadm settle

    # Mount root using direct partition path
    mount "$ROOT_PART" /mnt
    success "Mounted root at /mnt"

    # Mount boot using direct partition path
    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot
    success "Mounted boot at /mnt/boot"
}

# -----------------------------------------------------------------------------
# Clone Configuration
# -----------------------------------------------------------------------------
clone_config() {
    info "Cloning NixOS configuration..."

    # Create user home directory
    mkdir -p "/mnt/home/$USERNAME"

    # Clone the configuration repository
    git clone "$REPO_URL" "/mnt/home/$USERNAME/nixos-config"
    success "Configuration cloned to /mnt/home/$USERNAME/nixos-config"

    # Generate hardware configuration for this specific machine
    info "Generating hardware configuration..."
    nixos-generate-config --root /mnt --show-hardware-config > "/mnt/home/$USERNAME/nixos-config/hosts/$FLAKE_HOST/hardware-configuration.nix"
    success "Hardware configuration generated"

    # Update stateVersion to match current NixOS release
    info "Updating stateVersion to current release..."
    CURRENT_VERSION=$(nixos-version | cut -d. -f1,2)
    CONFIG_DIR="/mnt/home/$USERNAME/nixos-config"

    sed -i "s/stateVersion = \"[0-9.]*\"/stateVersion = \"$CURRENT_VERSION\"/" \
        "$CONFIG_DIR/hosts/$FLAKE_HOST/host.nix" \
        "$CONFIG_DIR/users/$USERNAME/user.nix"
    success "Updated stateVersion to $CURRENT_VERSION"
}

# -----------------------------------------------------------------------------
# Create Secure Boot Keys
# -----------------------------------------------------------------------------
create_secureboot_keys() {
    info "Creating secure boot keys for Lanzaboote..."

    # Create the sbctl directory structure (explicit for compatibility)
    mkdir -p /mnt/var/lib/sbctl/keys/PK
    mkdir -p /mnt/var/lib/sbctl/keys/KEK
    mkdir -p /mnt/var/lib/sbctl/keys/db
    chmod -R 700 /mnt/var/lib/sbctl

    # Get openssl from nixpkgs (not in default live ISO)
    OPENSSL="$(nix-build '<nixpkgs>' -A openssl --no-out-link)/bin/openssl"

    # Generate keys manually with openssl (avoids sbctl permission issues)
    info "Generating Platform Key (PK)..."
    "$OPENSSL" req -new -x509 -newkey rsa:4096 -nodes -days 3650 \
        -subj "/CN=Platform Key/" \
        -keyout /mnt/var/lib/sbctl/keys/PK/PK.key \
        -out /mnt/var/lib/sbctl/keys/PK/PK.pem

    info "Generating Key Exchange Key (KEK)..."
    "$OPENSSL" req -new -x509 -newkey rsa:4096 -nodes -days 3650 \
        -subj "/CN=Key Exchange Key/" \
        -keyout /mnt/var/lib/sbctl/keys/KEK/KEK.key \
        -out /mnt/var/lib/sbctl/keys/KEK/KEK.pem

    info "Generating Signature Database Key (db)..."
    "$OPENSSL" req -new -x509 -newkey rsa:4096 -nodes -days 3650 \
        -subj "/CN=Signature Database Key/" \
        -keyout /mnt/var/lib/sbctl/keys/db/db.key \
        -out /mnt/var/lib/sbctl/keys/db/db.pem

    success "Secure boot keys created at /mnt/var/lib/sbctl"
}

# -----------------------------------------------------------------------------
# Install NixOS
# -----------------------------------------------------------------------------
install_nixos() {
    info "Installing NixOS (this may take a while)..."
    echo ""

    nixos-install \
        --flake "/mnt/home/$USERNAME/nixos-config#$FLAKE_HOST" \
        --no-root-passwd

    success "NixOS installation complete!"

    # Fix ownership of config directory (cloned as root)
    info "Fixing config directory ownership..."
    chown -R 1000:100 "/mnt/home/$USERNAME"
    success "Config directory owned by $USERNAME"

    # Set user password
    info "Set password for $USERNAME:"
    nixos-enter --root /mnt -c "passwd $USERNAME"
    success "User password set"
}

# -----------------------------------------------------------------------------
# Post-install message
# -----------------------------------------------------------------------------
post_install() {
    echo ""
    echo "============================================================"
    success "Installation Complete!"
    echo "============================================================"
    echo ""
    info "Next steps:"
    echo "  1. Reboot into your new system: reboot"
    echo "  2. Log in as '$USERNAME' with the password you just set"
    echo ""
    warn "Secure Boot Setup (Lanzaboote):"
    echo "  Temporary keys were generated to complete installation."
    echo "  To enable Secure Boot, follow these steps after first boot:"
    echo ""
    echo "  1. Regenerate proper keys with sbctl:"
    echo "     sudo rm -rf /var/lib/sbctl"
    echo "     sudo sbctl create-keys"
    echo "  2. Enter BIOS and enable Secure Boot in 'Setup Mode'"
    echo "     (Setup Mode clears existing keys and allows enrollment)"
    echo "  3. Boot into NixOS and enroll keys:"
    echo "     sudo sbctl enroll-keys --microsoft"
    echo "  4. Reboot, change Secure Boot from Setup Mode to Enabled"
    echo "  5. Verify with: sbctl status"
    echo ""
    info "Your configuration is at: /home/$USERNAME/nixos-config"
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo "============================================================"
    echo "          NixOS Installation Script"
    echo "============================================================"
    echo ""

    check_prerequisites
    select_disk
    partition_disk
    format_partitions
    mount_partitions
    clone_config
    create_secureboot_keys
    install_nixos
    post_install
}

main "$@"
