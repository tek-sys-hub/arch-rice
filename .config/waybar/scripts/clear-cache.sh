#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║  clear-cache.sh  -  Safe user cache cleaner               ║
# ║  Only removes known-safe disposable cache dirs           ║
# ║  Never touches IDE, system, or important app data        ║
# ╚══════════════════════════════════════════════════════════╝

FREED=0
LOG=""

safe_rm() {
    local path="$1"
    local label="$2"
    if [[ -e "$path" ]]; then
        local size
        size=$(du -sb "$path" 2>/dev/null | awk '{print $1}')
        rm -rf "$path"
        FREED=$(( FREED + size ))
        LOG="$LOG\n  ✓ $label"
    fi
}

# ── Thumbnails & image caches ─────────────────────────────
safe_rm "$HOME/.cache/thumbnails"         "Thumbnails cache"
safe_rm "$HOME/.cache/wallpaper-thumbs"   "Wallpaper thumbnails"
safe_rm "$HOME/.cache/ImageMagick"        "ImageMagick cache"
safe_rm "$HOME/.cache/glycin"             "Glycin image cache"

# ── Package manager caches (yay AUR downloaded tarballs) ──
safe_rm "$HOME/.cache/yay"                "Yay AUR download cache"

# ── Font/shader caches (auto-regenerated) ─────────────────
safe_rm "$HOME/.cache/fontconfig"         "Fontconfig cache"
safe_rm "$HOME/.cache/mesa_shader_cache"  "Mesa shader cache"
safe_rm "$HOME/.cache/radv_builtin_shaders" "RADV shader cache"
safe_rm "$HOME/.cache/qtshadercache-x86_64-little_endian-lp64" "Qt shader cache"

# ── App caches (auto-regenerated, safe to clear) ──────────
safe_rm "$HOME/.cache/rofi3.druncache"    "Rofi cache"
safe_rm "$HOME/.cache/rofi-entry-history.txt" "Rofi history"
safe_rm "$HOME/.cache/appstream"          "AppStream cache"
safe_rm "$HOME/.cache/ksycoca6"*          "KSycoca cache"
safe_rm "$HOME/.cache/kwin"               "KWin cache"
safe_rm "$HOME/.cache/kitty"              "Kitty cache"
safe_rm "$HOME/.cache/gitstatus"          "Gitstatus cache"
safe_rm "$HOME/.cache/vim"                "Vim cache"
safe_rm "$HOME/.cache/p10k-tekra"         "Powerlevel10k cache"
safe_rm "$HOME/.cache/awww"               "Awww wallpaper cache"
safe_rm "$HOME/.cache/awww-wal"           "Awww-wal cache"
safe_rm "$HOME/.cache/fish"               "Fish shell cache"
safe_rm "$HOME/.cache/jedi"               "Jedi Python cache"
safe_rm "$HOME/.cache/gtk-4.0"            "GTK4 icon cache"
safe_rm "$HOME/.cache/syft"               "Syft cache"
safe_rm "$HOME/.cache/mpv"                "MPV cache"

# ── Python pip cache ──────────────────────────────────────
safe_rm "$HOME/.cache/pip"                "Pip package cache"

# ── Node/npm build caches ─────────────────────────────────
safe_rm "$HOME/.cache/node-gyp"           "Node-gyp cache"

# ── Recreate thumbnails dir (avoids GTK warnings) ─────────
mkdir -p "$HOME/.cache/thumbnails/normal"
mkdir -p "$HOME/.cache/thumbnails/large"

# ── Regenerate font cache ─────────────────────────────────
fc-cache -f &>/dev/null &

# ── Summarize ─────────────────────────────────────────────
FREED_MB=$(( FREED / 1024 / 1024 ))
FREED_HUMAN="${FREED_MB}MB"
if (( FREED_MB >= 1024 )); then
    FREED_GB=$(echo "scale=1; $FREED_MB / 1024" | bc)
    FREED_HUMAN="${FREED_GB}GB"
fi

notify-send \
    --icon=user-trash \
    --urgency=normal \
    --expire-time=4000 \
    "🧹 Cache Cleared" \
    "Freed ${FREED_HUMAN} of disposable cache.\n(IDE data, system files untouched)"

echo "Freed: $FREED_HUMAN"
