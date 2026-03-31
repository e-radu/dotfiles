#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
skip()    { echo -e "${YELLOW}[SKIP]${NC} $1 — not installed"; }
fail()    { echo -e "${RED}[FAIL]${NC} $1"; }

separator() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ── Neovim ──────────────────────────────────────────────
separator
if command -v nvim &>/dev/null; then
    info "Updating Neovim..."
    echo "  Current: $(nvim --version | head -1)"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz
    echo "  Updated: $(nvim --version | head -1)"
    success "Neovim updated"
else
    skip "Neovim"
fi

# ── Lazygit ─────────────────────────────────────────────
separator
if command -v lazygit &>/dev/null; then
    info "Updating lazygit..."
    echo "  Current: $(lazygit --version)"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
    echo "  Updated: $(lazygit --version)"
    success "lazygit updated"
else
    skip "lazygit"
fi

# ── Starship ────────────────────────────────────────────
separator
if command -v starship &>/dev/null; then
    info "Updating Starship..."
    echo "  Current: $(starship -V)"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "  Updated: $(starship -V)"
    success "Starship updated"
else
    skip "Starship"
fi

# ── Rust / Cargo ────────────────────────────────────────
separator
if command -v rustup &>/dev/null; then
    info "Updating Rust toolchain..."
    echo "  Current: $(rustc --version)"
    rustup update
    echo "  Updated: $(rustc --version)"
    success "Rust updated"
else
    skip "Rust/Cargo"
fi

# ── fzf ─────────────────────────────────────────────────
separator
if command -v fzf &>/dev/null && [ -d "$HOME/.fzf" ]; then
    info "Updating fzf..."
    echo "  Current: $(fzf --version)"
    git -C "$HOME/.fzf" pull
    "$HOME/.fzf/install" --all --no-bash --no-fish
    echo "  Updated: $(fzf --version)"
    success "fzf updated"
else
    skip "fzf"
fi

# ── Atuin ───────────────────────────────────────────────
separator
if command -v atuin &>/dev/null; then
    info "Updating Atuin..."
    echo "  Current: $(atuin --version)"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    echo "  Updated: $(atuin --version)"
    success "Atuin updated"
else
    skip "Atuin"
fi

# ── APT packages ────────────────────────────────────────
separator
info "Updating APT packages via nala..."
sudo nala upgrade -y
success "APT packages updated"

separator
echo -e "${GREEN}All updates complete!${NC}"
