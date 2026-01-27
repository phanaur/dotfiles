#!/bin/bash
# ============================================================================
# Sync Configurations to Dotfiles Repository
# Run this script to update the dotfiles repo with your current configs
# ============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Syncing configurations to dotfiles repository..."
echo "Target: $DOTFILES_DIR"
echo ""

# Create directory structure
mkdir -p "$DOTFILES_DIR/nvim"
mkdir -p "$DOTFILES_DIR/helix"
mkdir -p "$DOTFILES_DIR/templates"
mkdir -p "$DOTFILES_DIR/scripts"
mkdir -p "$DOTFILES_DIR/docs"

# ============================================================================
# 1. Neovim Configuration
# ============================================================================

echo "[1/6] Syncing Neovim configuration..."

# Copy entire nvim config (excluding generated files)
rsync -av --exclude='lazy-lock.json' \
          --exclude='.luarc.json' \
          --exclude='*.backup*' \
          --exclude='.git' \
          "$HOME/.config/nvim/" "$DOTFILES_DIR/nvim/"

echo "  ✓ Neovim config synced"

# ============================================================================
# 2. Helix Configuration
# ============================================================================

echo "[2/6] Syncing Helix configuration..."

# Copy helix config (excluding runtime)
rsync -av --exclude='runtime' \
          --exclude='*.backup*' \
          --exclude='.git' \
          "$HOME/.config/helix/" "$DOTFILES_DIR/helix/"

echo "  ✓ Helix config synced (runtime excluded)"

# ============================================================================
# 3. Templates
# ============================================================================

echo "[3/6] Syncing templates..."

# Copy templates if they exist
if [ -f "$HOME/.editorconfig.csharp-template" ]; then
    cp "$HOME/.editorconfig.csharp-template" "$DOTFILES_DIR/templates/.editorconfig.csharp"
    echo "  ✓ .editorconfig template synced"
fi

if [ -f "$HOME/omnisharp.json.template" ]; then
    cp "$HOME/omnisharp.json.template" "$DOTFILES_DIR/templates/omnisharp.json"
    echo "  ✓ omnisharp.json template synced"
fi

# Also copy from test project if templates don't exist in home
if [ -f "/tmp/test-nvim-csharp/.editorconfig" ] && [ ! -f "$DOTFILES_DIR/templates/.editorconfig.csharp" ]; then
    cp "/tmp/test-nvim-csharp/.editorconfig" "$DOTFILES_DIR/templates/.editorconfig.csharp"
    echo "  ✓ .editorconfig template synced from test project"
fi

if [ -f "/tmp/test-nvim-csharp/omnisharp.json" ] && [ ! -f "$DOTFILES_DIR/templates/omnisharp.json" ]; then
    cp "/tmp/test-nvim-csharp/omnisharp.json" "$DOTFILES_DIR/templates/omnisharp.json"
    echo "  ✓ omnisharp.json template synced from test project"
fi

# ============================================================================
# 4. Scripts
# ============================================================================

echo "[4/6] Syncing scripts..."

if [ -f "$HOME/setup-dev-env.sh" ]; then
    cp "$HOME/setup-dev-env.sh" "$DOTFILES_DIR/scripts/setup-dev-env.sh"
    chmod +x "$DOTFILES_DIR/scripts/setup-dev-env.sh"
    echo "  ✓ setup-dev-env.sh synced"
fi

# ============================================================================
# 5. Documentation
# ============================================================================

echo "[5/6] Syncing documentation..."

# Copy all markdown guides
for doc in DIAGNOSTICOS NOTIFICACIONES AUTOGUARDADO HELIX-AUTOSAVE HELIX-OMNISHARP OMNISHARP-CONFIG GUIA-CSHARP SETUP-README; do
    if [ -f "$HOME/${doc}.md" ]; then
        cp "$HOME/${doc}.md" "$DOTFILES_DIR/docs/"
        echo "  ✓ ${doc}.md synced"
    fi

    # Also check in .config/nvim
    if [ -f "$HOME/.config/nvim/${doc}.md" ]; then
        cp "$HOME/.config/nvim/${doc}.md" "$DOTFILES_DIR/docs/"
        echo "  ✓ ${doc}.md synced (from nvim config)"
    fi
done

# ============================================================================
# 6. Git Status
# ============================================================================

echo "[6/6] Checking git status..."
echo ""

cd "$DOTFILES_DIR"

if [ -d .git ]; then
    echo "Git status:"
    git status --short
    echo ""
    echo "Files synced! Review changes above."
    echo ""
    echo "To commit and push:"
    echo "  cd $DOTFILES_DIR"
    echo "  git add ."
    echo "  git commit -m 'Update configs'"
    echo "  git push"
else
    echo "Not a git repository. Initialize with:"
    echo "  cd $DOTFILES_DIR"
    echo "  git init"
    echo "  git add ."
    echo "  git commit -m 'Initial commit'"
    echo "  git remote add origin git@github.com:tu-usuario/dotfiles.git"
    echo "  git push -u origin main"
fi

echo ""
echo "✓ Sync complete!"
