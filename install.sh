#!/usr/bin/env bash
# install.sh — install kitty + the kawaii fastfetch config for the current user.
# Targets Arch-based systems (Ryoku / Arch / CachyOS). Run as your normal user;
# it will use sudo only for pacman.
set -euo pipefail

say() { printf '\033[1;35m♡\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

# --- dependencies -----------------------------------------------------------
if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found — this script targets Arch-based systems." >&2
    exit 1
fi

need=()
command -v kitty     >/dev/null 2>&1 || need+=(kitty)
command -v fastfetch >/dev/null 2>&1 || need+=(fastfetch)
if (( ${#need[@]} > 0 )); then
    say "Installing: ${need[*]}"
    sudo pacman -S --needed --noconfirm "${need[@]}"
fi

# --- directories ------------------------------------------------------------
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$cfg/fastfetch" "$HOME/Images/ryoemblems"

# --- fastfetch config ------------------------------------------------------
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$script_dir/config.jsonc" ]]; then
    cp "$script_dir/config.jsonc" "$cfg/fastfetch/config.jsonc"
    say "fastfetch config installed -> $cfg/fastfetch/config.jsonc"
else
    warn "config.jsonc not found next to install.sh"
fi

# --- emblem (optional) -----------------------------------------------------
if [[ -f "$script_dir/preview.png" && ! -f "$HOME/Images/ryoemblems/loli.png" ]]; then
    cp "$script_dir/preview.png" "$HOME/Images/ryoemblems/loli.png"
    say "emblem installed -> ~/Images/ryoemblems/loli.png"
fi

# --- kitty user overrides (cute glass + borders) ----------------------------
kitty_user="$cfg/kitty/user.conf"
if [[ ! -f "$kitty_user" ]]; then
    mkdir -p "$cfg/kitty"
    cat > "$kitty_user" <<'EOF'
# User overrides (never shipped, never touched on update)

# Glass terminal
background_opacity 0.6
background_blur 3
text_contrast 40
dynamic_background_opacity yes

# Cute interior borders
window_padding_width 14
window_margin_width 8
window_border_width 2
active_border_color #ff69b4
inactive_border_color #6bb6ff
bell_border_color #ff69b4
draw_minimal_borders no
EOF
    say "kitty user.conf created"
else
    say "kitty user.conf already exists — left untouched"
fi

say "done! open a new kitty and run: fastfetch"
say "♡ have a cute day ♡"
