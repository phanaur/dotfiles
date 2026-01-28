#!/bin/bash
# ============================================================================
# Verify Neovim Configuration
# Checks that all essential plugin files are present
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "======================================================================"
echo "Neovim Configuration Verification"
echo "======================================================================"
echo ""

NVIM_CONFIG="$HOME/.config/nvim"
PLUGINS_DIR="$NVIM_CONFIG/lua/plugins"

# Check if Neovim config exists
if [ ! -d "$NVIM_CONFIG" ]; then
    echo -e "${RED}✗ Neovim config directory not found: $NVIM_CONFIG${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Neovim config directory exists${NC}"
echo ""

# Essential plugin files to check
declare -A FILES=(
    ["$PLUGINS_DIR/languages.lua"]="Multi-language support"
    ["$PLUGINS_DIR/csharp-roslyn.lua"]="Roslyn LSP for C# (CRITICAL)"
    ["$PLUGINS_DIR/autosave.lua"]="Auto-save functionality"
    ["$PLUGINS_DIR/diagnostics.lua"]="Enhanced diagnostics"
    ["$PLUGINS_DIR/notifications.lua"]="Notification settings"
)

echo "Checking essential plugin files:"
echo ""

MISSING=0
for file in "${!FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} ${FILES[$file]}"
        echo "  → $file"
    else
        echo -e "${RED}✗${NC} ${FILES[$file]} - MISSING"
        echo "  → $file"
        MISSING=$((MISSING + 1))
    fi
    echo ""
done

# Check if Roslyn plugin is configured
if [ -f "$PLUGINS_DIR/csharp-roslyn.lua" ]; then
    if grep -q "seblj/roslyn.nvim" "$PLUGINS_DIR/csharp-roslyn.lua"; then
        echo -e "${GREEN}✓ Roslyn LSP plugin is configured${NC}"
    else
        echo -e "${YELLOW}⚠ csharp-roslyn.lua exists but doesn't configure roslyn.nvim${NC}"
        MISSING=$((MISSING + 1))
    fi
else
    echo -e "${RED}✗ csharp-roslyn.lua is MISSING - C# diagnostics won't work!${NC}"
fi

echo ""
echo "======================================================================"

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✓ All configuration files are present!${NC}"
    echo ""
    echo "If C# diagnostics still don't work:"
    echo "  1. Open Neovim: nvim"
    echo "  2. Wait for Lazy to sync plugins"
    echo "  3. Check :Lazy status"
    echo "  4. Open a .cs file and wait a few seconds"
    echo "  5. Check :LspInfo to see if Roslyn is attached"
else
    echo -e "${RED}✗ $MISSING configuration file(s) missing!${NC}"
    echo ""
    echo "To fix:"
    echo "  cd ~/github/dotfiles"
    echo "  git pull"
    echo "  ./scripts/setup-dev-env.sh"
    echo ""
    echo "Or manually copy missing files from:"
    echo "  ~/github/dotfiles/nvim/lua/plugins/"
    echo "  to: $PLUGINS_DIR/"
fi

echo "======================================================================"
