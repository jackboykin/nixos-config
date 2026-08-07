#!/usr/bin/env bash
#
# NixOS Installation Script
# Automated reinstall from a live NixOS ISO
#
# Usage: bash <(curl -sL https://raw.githubusercontent.com/jackboykin/nixos-config/refs/heads/master/install.sh)
#

set -euo pipefail

REPO_URL="https://github.com/jackboykin/nixos-config"
FLAKE_HOST="nixos-orion"
USERNAME="jack"

# Cleanup mounts on failure
cleanup() {
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}[WARN]${NC} Installation failed. Cleaning up mounts..."
        umount -R /mnt 2>/dev/null || true
        umount /tmp/ventoy-mount 2>/dev/null || true
    fi
}
trap cleanup EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }

# -----------------------------------------------------------------------------
# Prerequisites Check
# -----------------------------------------------------------------------------
check_prerequisites() {
    info "Checking prerequisites..."

    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo bash install.sh"
    fi
    success "Running as root"

    if [[ ! -f /etc/NIXOS ]]; then
        error "This script must be run from a NixOS live ISO"
    fi
    success "Running on NixOS"

    for cmd in parted mkfs.fat mkfs.ext4 git nixos-install; do
        if ! command -v "$cmd" &>/dev/null; then
            error "Required command not found: $cmd"
        fi
    done
    success "All required tools available"

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

    if [[ ! -b "$TARGET_DISK" ]]; then
        error "Disk not found: $TARGET_DISK"
    fi

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

    umount -R /mnt 2>/dev/null || true
    for part in "${TARGET_DISK}"*; do
        umount "$part" 2>/dev/null || true
    done

    wipefs -af "$TARGET_DISK"
    parted -s "$TARGET_DISK" mklabel gpt
    parted -s "$TARGET_DISK" mkpart ESP fat32 1MiB 513MiB
    parted -s "$TARGET_DISK" set 1 esp on
    parted -s "$TARGET_DISK" mkpart root ext4 513MiB 100%

    sleep 2
    partprobe "$TARGET_DISK"
    sleep 1

    success "Partitioning complete"
}

# -----------------------------------------------------------------------------
# Determine partition names
# -----------------------------------------------------------------------------
get_partition_names() {
    if [[ "$TARGET_DISK" =~ nvme ]]; then
        EFI_PART="${TARGET_DISK}p1"
        ROOT_PART="${TARGET_DISK}p2"
    else
        EFI_PART="${TARGET_DISK}1"
        ROOT_PART="${TARGET_DISK}2"
    fi

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

    mkfs.fat -F 32 -n BOOT "$EFI_PART"
    success "Formatted EFI partition: $EFI_PART"

    mkfs.ext4 -L nixos -F "$ROOT_PART"
    success "Formatted root partition: $ROOT_PART"
}

# -----------------------------------------------------------------------------
# Mounting
# -----------------------------------------------------------------------------
mount_partitions() {
    info "Mounting partitions..."

    get_partition_names

    udevadm settle

    mount "$ROOT_PART" /mnt
    success "Mounted root at /mnt"

    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot
    success "Mounted boot at /mnt/boot"
}

# -----------------------------------------------------------------------------
# Clone Configuration
# -----------------------------------------------------------------------------
clone_config() {
    info "Cloning NixOS configuration..."

    mkdir -p "/mnt/home/$USERNAME"
    git clone "$REPO_URL" "/mnt/home/$USERNAME/nixos-config"
    success "Configuration cloned to /mnt/home/$USERNAME/nixos-config"

    info "Generating hardware configuration..."
    nixos-generate-config --root /mnt --show-hardware-config > "/mnt/home/$USERNAME/nixos-config/hosts/$FLAKE_HOST/hardware-configuration.nix"
    success "Hardware configuration generated"

    info "Updating stateVersion to current release..."
    CURRENT_VERSION=$(nixos-version | cut -d. -f1,2)
    CONFIG_DIR="/mnt/home/$USERNAME/nixos-config"

    sed -i "s/stateVersion = \"[0-9.]*\"/stateVersion = \"$CURRENT_VERSION\"/" \
        "$CONFIG_DIR/hosts/$FLAKE_HOST/host.nix"
    success "Updated stateVersion to $CURRENT_VERSION"
}

# -----------------------------------------------------------------------------
# Create Secure Boot Keys
# -----------------------------------------------------------------------------
create_secureboot_keys() {
    info "Creating secure boot keys for Lanzaboote..."

    mkdir -p /mnt/var/lib/sbctl/keys/PK
    mkdir -p /mnt/var/lib/sbctl/keys/KEK
    mkdir -p /mnt/var/lib/sbctl/keys/db
    chmod -R 700 /mnt/var/lib/sbctl

    OPENSSL="$(nix-build '<nixpkgs>' -A openssl --no-out-link)/bin/openssl"
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
# Setup SOPS Age Key from Ventoy USB
# -----------------------------------------------------------------------------
setup_sops_key() {
    info "Looking for age key on Ventoy USB..."

    VENTOY_PART=""
    VENTOY_MOUNT="/tmp/ventoy-mount"

    if [[ -b /dev/disk/by-label/Ventoy ]]; then
        VENTOY_PART="/dev/disk/by-label/Ventoy"
    else
        for part in /dev/sd*[0-9] /dev/nvme*p[0-9]; do
            if [[ -b "$part" ]] && blkid "$part" 2>/dev/null | grep -q "Ventoy"; then
                VENTOY_PART="$part"
                break
            fi
        done
    fi

    if [[ -z "$VENTOY_PART" ]]; then
        error "Ventoy USB not found. The age key is required for sops-nix to decrypt the user password."
    fi

    info "Found Ventoy at $VENTOY_PART"

    # Use existing mount if Ventoy is already mounted (e.g., booting from the same USB)
    EXISTING_MOUNT=$(findmnt -n -o TARGET "$VENTOY_PART" 2>/dev/null || true)
    if [[ -n "$EXISTING_MOUNT" ]]; then
        VENTOY_MOUNT="$EXISTING_MOUNT"
        VENTOY_MOUNTED_BY_US=false
        info "Ventoy already mounted at $VENTOY_MOUNT"
    else
        mkdir -p "$VENTOY_MOUNT"
        mount -o ro "$VENTOY_PART" "$VENTOY_MOUNT"
        VENTOY_MOUNTED_BY_US=true
    fi

    KEY_FILE=""
    for path in "$VENTOY_MOUNT/key.txt" "$VENTOY_MOUNT/keys.txt" "$VENTOY_MOUNT/sops/key.txt" "$VENTOY_MOUNT/secrets/key.txt"; do
        if [[ -f "$path" ]]; then
            KEY_FILE="$path"
            break
        fi
    done

    if [[ -z "$KEY_FILE" ]]; then
        [[ "$VENTOY_MOUNTED_BY_US" == true ]] && umount "$VENTOY_MOUNT"
        error "age key not found on Ventoy USB. Looked in: /key.txt, /keys.txt, /sops/key.txt, /secrets/key.txt"
    fi

    info "Found age key at $KEY_FILE"

    # Validate the key looks like an age secret key
    if ! grep -q "^AGE-SECRET-KEY-" "$KEY_FILE"; then
        [[ "$VENTOY_MOUNTED_BY_US" == true ]] && umount "$VENTOY_MOUNT"
        error "keys.txt does not contain a valid age secret key"
    fi

    mkdir -p /mnt/var/lib/sops-nix
    cp "$KEY_FILE" /mnt/var/lib/sops-nix/key.txt
    chmod 600 /mnt/var/lib/sops-nix/key.txt

    [[ "$VENTOY_MOUNTED_BY_US" == true ]] && umount "$VENTOY_MOUNT"
    success "SOPS age key installed to /mnt/var/lib/sops-nix/key.txt"
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

    info "Fixing config directory ownership..."
    USER_UID=$(nixos-enter --root /mnt -c "id -u $USERNAME")
    USER_GID=$(nixos-enter --root /mnt -c "id -g $USERNAME")
    chown -R "$USER_UID:$USER_GID" "/mnt/home/$USERNAME"
    success "Config directory owned by $USERNAME ($USER_UID:$USER_GID)"

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
    echo "  2. Log in as '$USERNAME' (password is managed by sops-nix)"
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
    setup_sops_key
    install_nixos
    post_install
}

main "$@"
