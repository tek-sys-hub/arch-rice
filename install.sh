#!/usr/bin/env bash
# ==============================================================================
#   ____ _                         ____  _          
#  / ___| |__   ___ _ __ _ __ _   |  _ \(_) ___ ___ 
# | |   | '_ \ / _ \ '__| '__| | | | |_) | |/ __/ _ \
# | |___| | | |  __/ |  | |  | |_| |  _ <| | (_|  __/
#  \____|_| |_|\___|_|  |_|   \__, |_| \_\_|\___\___|
#                              |___/                
#  Cherry Arch Linux + Hyprland Rice Installer
#  Repository: tek-sys-hub/arch-rice
#  Author: Cherry
# ==============================================================================

set -eo pipefail

# ── Color Palette ─────────────────────────────────────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RESET="\033[0m"

log_info()    { printf "${BLUE}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
log_success() { printf "${GREEN}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
log_warn()    { printf "${YELLOW}==> WARNING:${RESET} %s\n" "$1"; }
log_error()   { printf "${RED}==> ERROR:${RESET} %s\n" "$1" >&2; }
log_step()    { printf "${CYAN}::${RESET} ${BOLD}%s${RESET}\n" "$1"; }

# ── Command Line Flags ────────────────────────────────────────────────────────
ASSUME_YES=false
DRY_RUN=false
SKIP_PKGS=false

for arg in "$@"; do
    case "$arg" in
        -y|--yes)
            ASSUME_YES=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --skip-packages)
            SKIP_PKGS=true
            ;;
        -h|--help)
            cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  -y, --yes          Non-interactive mode (automatically accept prompts)
  --skip-packages    Skip installing system packages and AUR dependencies
  --dry-run          Simulate installation without modifying files
  -h, --help         Show this help message and exit
EOF
            exit 0
            ;;
        *)
            log_warn "Unknown option: $arg"
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Print Banner ──────────────────────────────────────────────────────────────
print_banner() {
    clear 2>/dev/null || true
    printf "${MAGENTA}${BOLD}"
    cat << "EOF"
   ____ _                         ____  _          
  / ___| |__   ___ _ __ _ __ _   |  _ \(_) ___ ___ 
 | |   | '_ \ / _ \ '__| '__| | | | |_) | |/ __/ _ \
 | |___| | | |  __/ |  | |  | |_| |  _ <| | (_|  __/
  \____|_| |_|\___|_|  |_|   \__, |_| \_\_|\___\___|
                              |___/                
EOF
    printf "${RESET}"
    printf "${CYAN}${BOLD}   ✦ Arch Linux + Hyprland Rice Deployment Suite ✦${RESET}\n"
    printf "${DIM}   Author: Cherry | Repository: tek-sys-hub/arch-rice${RESET}\n\n"
}

# ── Pre-flight Checks ─────────────────────────────────────────────────────────
preflight_checks() {
    log_step "Running pre-flight checks..."

    if [[ "$EUID" -eq 0 ]]; then
        log_error "Please do NOT run this script as root or with sudo!"
        log_error "It must be executed as your regular desktop user."
        exit 1
    fi

    if [[ ! -f /etc/arch-release ]] && ! grep -qi "arch" /etc/os-release 2>/dev/null; then
        log_warn "This system does not appear to be Arch Linux or Arch-based."
        if [[ "$ASSUME_YES" != true ]]; then
            read -rp "Do you wish to proceed anyway? [y/N]: " confirm
            [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
        fi
    else
        log_success "Arch Linux environment verified."
    fi

    # AUR Helper Detection
    AUR_HELPER=""
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    fi

    if [[ -z "$AUR_HELPER" ]]; then
        log_warn "Neither 'yay' nor 'paru' was detected."
        log_info "An AUR helper is required for packages like quickshell-git and awww."
        if [[ "$ASSUME_YES" != true ]]; then
            read -rp "Would you like to install 'yay' now? [Y/n]: " inst_yay
            if [[ ! "$inst_yay" =~ ^[Nn]$ ]]; then
                install_yay
                AUR_HELPER="yay"
            fi
        fi
    else
        log_success "Found AUR helper: ${AUR_HELPER}"
    fi
}

install_yay() {
    log_step "Installing yay-bin..."
    sudo pacman -S --needed --noconfirm base-devel git
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"
    (cd "$tmp_dir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp_dir"
    log_success "yay installed successfully."
}

# ── Package Installation ──────────────────────────────────────────────────────
install_packages() {
    if [[ "$SKIP_PKGS" == true ]]; then
        log_info "Skipping package installation as requested."
        return
    fi

    log_step "Checking and installing required dependencies..."

    # Official Arch Repositories
    OFFICIAL_PKGS=(
        # Wayland & Compositor Stack
        hyprland
        hypridle
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        polkit-kde-agent
        wl-clipboard
        cliphist
        hyprpicker

        # Core Tools & Shell
        kitty
        fish
        fastfetch
        thunar
        btop
        bpytop
        cava
        yazi

        # Auxiliary Rice Components
        rofi
        waybar
        dunst
        wlogout

        # Media & Live Wallpaper
        ffmpeg
        mpv

        # Python Backend Daemon Dependencies
        python
        python-pillow
        python-numpy
        python-psutil
        python-jinja

        # Fonts & Appearance
        ttf-jetbrains-mono-nerd
        ttf-noto-nerd
        noto-fonts
        noto-fonts-emoji
        papirus-icon-theme
        bibata-cursor-theme
        adw-gtk-theme
        brightnessctl
        playerctl
    )

    # AUR Packages
    AUR_PKGS=(
        quickshell-git
        awww
        mpvpaper
    )

    log_info "Installing official repository packages via pacman..."
    if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: sudo pacman -S --needed ${OFFICIAL_PKGS[*]}"
    else
        sudo pacman -S --needed --noconfirm "${OFFICIAL_PKGS[@]}"
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        log_info "Installing AUR packages via ${AUR_HELPER}..."
        if [[ "$DRY_RUN" == true ]]; then
            echo "DRY RUN: ${AUR_HELPER} -S --needed ${AUR_PKGS[*]}"
        else
            "$AUR_HELPER" -S --needed --noconfirm "${AUR_PKGS[@]}" || {
                log_warn "Failed to install some AUR packages. Continuing with local configs..."
            }
        fi
    else
        log_warn "No AUR helper available; please manually install: ${AUR_PKGS[*]}"
    fi

    log_success "Packages installed."
}

# ── Backup Existing Configurations ────────────────────────────────────────────
backup_existing() {
    local backup_dir="$HOME/.config/backup-rice-$(date +%Y%m%d_%H%M%S)"
    local need_backup=false

    local targets=(
        hypr
        cherry
        quickshell
        kitty
        fish
        fastfetch
        waybar
        rofi
        dunst
        wlogout
        cava
        btop
        bpytop
        yazi
        gtk-3.0
        gtk-4.0
        fontconfig
        qtengine
    )

    for item in "${targets[@]}"; do
        if [[ -e "$HOME/.config/$item" ]]; then
            need_backup=true
            break
        fi
    done

    if [[ "$need_backup" == true ]]; then
        log_step "Backing up existing configurations to ${backup_dir}..."
        if [[ "$DRY_RUN" == true ]]; then
            echo "DRY RUN: mkdir -p $backup_dir and move existing configs"
        else
            mkdir -p "$backup_dir"
            for item in "${targets[@]}"; do
                if [[ -e "$HOME/.config/$item" ]]; then
                    cp -a "$HOME/.config/$item" "$backup_dir/"
                    log_info "Backed up: ~/.config/$item"
                fi
            done
            log_success "Backup preserved at: ${backup_dir}"
        fi
    else
        log_info "No conflicting configurations found to back up."
    fi
}

# ── Deploy Configurations ─────────────────────────────────────────────────────
deploy_configs() {
    log_step "Deploying Cherry's rice configurations..."

    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/Pictures/Wallpapers"

    if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: Copying .config/* to $HOME/.config/"
        echo "DRY RUN: Copying wallpapers/* to $HOME/Pictures/Wallpapers/"
        return
    fi

    # Copy all .config directories
    cp -a "$SCRIPT_DIR/.config/." "$HOME/.config/"

    # Set up Quickshell symlink
    rm -rf "$HOME/.config/quickshell" 2>/dev/null || true
    ln -sfn "$HOME/.config/cherry/shell" "$HOME/.config/quickshell"
    log_info "Linked ~/.config/quickshell -> ~/.config/cherry/shell"

    # Copy Wallpapers
    if [[ -d "$SCRIPT_DIR/wallpapers" ]]; then
        cp -a "$SCRIPT_DIR/wallpapers/." "$HOME/Pictures/Wallpapers/"
        log_info "Installed wallpapers into ~/Pictures/Wallpapers"
    fi

    # Fix dynamic paths for current user
    if [[ -f "$HOME/.config/qtengine/config.json" ]]; then
        sed -i "s|/home/[^/]*|/home/$USER|g" "$HOME/.config/qtengine/config.json"
    fi

    # Set initial wallpaper and state
    echo "$HOME/Pictures/Wallpapers/1407460.png" > "$HOME/.config/current-wallpaper"

    # Make all helper scripts executable
    find "$HOME/.config/hypr/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
    find "$HOME/.config/waybar/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
    find "$HOME/.config/rofi" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
    chmod +x "$HOME/.config/yazi/yazi-dbus.py" 2>/dev/null || true

    log_success "Configurations successfully deployed!"
}

# ── Setup User Systemd Services ───────────────────────────────────────────────
setup_services() {
    log_step "Configuring background daemons and systemd user units..."

    if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: systemctl --user daemon-reload && systemctl --user enable --now cherry-daemon.socket"
        return
    fi

    systemctl --user daemon-reload || true
    systemctl --user enable --now cherry-daemon.socket 2>/dev/null || true

    log_success "Cherry daemon socket enabled and active."
}

# ── Post-install & Summary ───────────────────────────────────────────────────
post_install() {
    log_step "Finalizing desktop environment..."

    if [[ "$DRY_RUN" != true ]]; then
        fc-cache -f 2>/dev/null || true
    fi

    printf "\n${GREEN}${BOLD}"
    cat << "EOF"
  =============================================================
   🎉 CONGRATULATIONS! CHERRY RICE INSTALLATION COMPLETE! 🎉
  =============================================================
EOF
    printf "${RESET}\n"

    printf "${CYAN}${BOLD}Key Shortcuts Cheatsheet:${RESET}\n"
    printf "  ${YELLOW}SUPER + RETURN${RESET}        Open Kitty Terminal\n"
    printf "  ${YELLOW}SUPER + SPACE${RESET}         App Launcher\n"
    printf "  ${YELLOW}SUPER + D${RESET}             Desktop Dashboard\n"
    printf "  ${YELLOW}SUPER + N${RESET}             Control Center\n"
    printf "  ${YELLOW}SUPER + W${RESET}             Wallpaper Selector\n"
    printf "  ${YELLOW}SUPER + T${RESET}             Dynamic Theme Switcher\n"
    printf "  ${YELLOW}SUPER + L${RESET}             Lock Screen (Cherry Lock)\n"
    printf "  ${YELLOW}SUPER + SHIFT + V${RESET}     Clipboard History Manager\n"
    printf "  ${YELLOW}SUPER + P${RESET}             Screenshot Tool\n"
    printf "  ${YELLOW}SUPER + X${RESET}             Power Menu\n"
    printf "  ${YELLOW}SUPER + Q${RESET}             Close Active Window\n\n"

    printf "${BLUE}${BOLD}Note:${RESET} It is strongly recommended to log out and log back in, or reboot your machine to apply all changes.\n\n"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    print_banner
    preflight_checks

    if [[ "$ASSUME_YES" != true ]]; then
        printf "${BOLD}This will install Cherry's Arch Hyprland Rice onto your system.${RESET}\n"
        read -rp "Are you ready to proceed? [Y/n]: " proceed
        if [[ "$proceed" =~ ^[Nn]$ ]]; then
            log_warn "Installation cancelled by user."
            exit 0
        fi
    fi

    install_packages
    backup_existing
    deploy_configs
    setup_services
    post_install
}

main "$@"
