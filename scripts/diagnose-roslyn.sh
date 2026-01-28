#!/bin/bash
# ============================================================================
# Diagnose Roslyn LSP Configuration
# Checks why Roslyn might not be working in Neovim
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================================================"
echo "Roslyn LSP Diagnostic Tool"
echo "======================================================================"
echo ""

# 1. Check if csharp-roslyn.lua exists
echo -e "${BLUE}[1/7] Checking csharp-roslyn.lua file...${NC}"
ROSLYN_FILE="$HOME/.config/nvim/lua/plugins/csharp-roslyn.lua"
if [ -f "$ROSLYN_FILE" ]; then
    echo -e "${GREEN}✓ File exists: $ROSLYN_FILE${NC}"
    if grep -q "seblj/roslyn.nvim" "$ROSLYN_FILE"; then
        echo -e "${GREEN}✓ File contains roslyn.nvim plugin${NC}"
    else
        echo -e "${RED}✗ File exists but doesn't configure roslyn.nvim!${NC}"
    fi
else
    echo -e "${RED}✗ File NOT found: $ROSLYN_FILE${NC}"
    echo "  Run: cp ~/github/dotfiles/nvim/lua/plugins/csharp-roslyn.lua $ROSLYN_FILE"
fi
echo ""

# 2. Check if .NET SDK is installed
echo -e "${BLUE}[2/7] Checking .NET SDK...${NC}"
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo -e "${GREEN}✓ .NET SDK installed: $DOTNET_VERSION${NC}"

    # Check if version is 8.0 or higher
    MAJOR_VERSION=$(echo $DOTNET_VERSION | cut -d. -f1)
    if [ "$MAJOR_VERSION" -ge 8 ]; then
        echo -e "${GREEN}✓ .NET version is compatible (8.0+)${NC}"
    else
        echo -e "${YELLOW}⚠ .NET version is old. Roslyn requires .NET 8.0+${NC}"
    fi
else
    echo -e "${RED}✗ .NET SDK not found!${NC}"
    echo "  Install: sudo dnf install -y dotnet-sdk-10.0"
fi
echo ""

# 3. Check Lazy plugin directory
echo -e "${BLUE}[3/7] Checking Lazy plugins directory...${NC}"
LAZY_DIR="$HOME/.local/share/nvim/lazy"
if [ -d "$LAZY_DIR" ]; then
    echo -e "${GREEN}✓ Lazy plugins directory exists${NC}"

    # Check if roslyn.nvim is installed
    if [ -d "$LAZY_DIR/roslyn.nvim" ]; then
        echo -e "${GREEN}✓ roslyn.nvim plugin is installed${NC}"

        # Check if it has the main files
        if [ -f "$LAZY_DIR/roslyn.nvim/lua/roslyn/init.lua" ]; then
            echo -e "${GREEN}✓ roslyn.nvim appears complete${NC}"
        else
            echo -e "${YELLOW}⚠ roslyn.nvim is installed but might be incomplete${NC}"
        fi
    else
        echo -e "${RED}✗ roslyn.nvim plugin NOT installed!${NC}"
        echo "  Open nvim and run: :Lazy install roslyn.nvim"
    fi
else
    echo -e "${YELLOW}⚠ Lazy plugins directory not found${NC}"
    echo "  This is normal for first-time setup. Open nvim to initialize."
fi
echo ""

# 4. Check Roslyn LSP server
echo -e "${BLUE}[4/7] Checking Roslyn LSP server...${NC}"
ROSLYN_SERVER="$HOME/.local/share/nvim/roslyn"
if [ -d "$ROSLYN_SERVER" ]; then
    echo -e "${GREEN}✓ Roslyn server directory exists${NC}"

    # Check for Microsoft.CodeAnalysis.LanguageServer
    if find "$ROSLYN_SERVER" -name "Microsoft.CodeAnalysis.LanguageServer.dll" 2>/dev/null | grep -q .; then
        echo -e "${GREEN}✓ Roslyn LSP server binaries found${NC}"
    else
        echo -e "${YELLOW}⚠ Roslyn server directory exists but binaries not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Roslyn server not installed yet${NC}"
    echo "  This is normal. It downloads on first use of a .cs file."
fi
echo ""

# 5. Check LazyVim C# extras
echo -e "${BLUE}[5/7] Checking LazyVim configuration...${NC}"
LAZY_CONFIG="$HOME/.config/nvim/lua/config/lazy.lua"
if [ -f "$LAZY_CONFIG" ]; then
    echo -e "${GREEN}✓ lazy.lua config exists${NC}"

    if grep -q "lang.csharp" "$LAZY_CONFIG" 2>/dev/null; then
        echo -e "${GREEN}✓ C# language extras enabled in lazy.lua${NC}"
    else
        echo -e "${YELLOW}⚠ C# language extras not found in lazy.lua${NC}"
        echo "  This is OK if using custom csharp-roslyn.lua"
    fi
else
    echo -e "${YELLOW}⚠ lazy.lua not found${NC}"
fi
echo ""

# 6. Test Neovim headless
echo -e "${BLUE}[6/7] Testing Neovim Lua configuration...${NC}"
TEST_RESULT=$(nvim --headless -c "lua local ok, roslyn = pcall(require, 'roslyn'); print(ok)" -c "qa" 2>&1 | tail -1)
if echo "$TEST_RESULT" | grep -q "true"; then
    echo -e "${GREEN}✓ Roslyn module can be loaded${NC}"
else
    echo -e "${YELLOW}⚠ Roslyn module not available (might need :Lazy sync)${NC}"
fi
echo ""

# 7. Check for common issues
echo -e "${BLUE}[7/7] Checking for common issues...${NC}"

# Check if nvim is running
if pgrep -x nvim > /dev/null; then
    echo -e "${YELLOW}⚠ Neovim is currently running${NC}"
    echo "  If you just copied csharp-roslyn.lua, restart Neovim!"
else
    echo -e "${GREEN}✓ No Neovim instances running${NC}"
fi

# Check lazy-lock.json
LAZY_LOCK="$HOME/.config/nvim/lazy-lock.json"
if [ -f "$LAZY_LOCK" ]; then
    if grep -q "roslyn.nvim" "$LAZY_LOCK"; then
        echo -e "${GREEN}✓ roslyn.nvim is in lazy-lock.json${NC}"
    else
        echo -e "${YELLOW}⚠ roslyn.nvim not in lazy-lock.json${NC}"
        echo "  Run :Lazy sync in Neovim"
    fi
fi

echo ""
echo "======================================================================"
echo "Diagnosis Summary"
echo "======================================================================"
echo ""

# Provide recommendations
echo "Next steps to try:"
echo ""
echo "1. If Neovim was running when you copied files:"
echo "   → Close Neovim completely and reopen"
echo ""
echo "2. If roslyn.nvim is not installed:"
echo "   nvim"
echo "   :Lazy sync"
echo "   :qa"
echo ""
echo "3. Open a C# project and wait 30 seconds:"
echo "   cd /path/to/csharp/project"
echo "   nvim Program.cs"
echo "   # Wait for Roslyn to download (first time only)"
echo ""
echo "4. Check LSP status while in a .cs file:"
echo "   :LspInfo"
echo "   # Should show 'roslyn' as attached"
echo ""
echo "5. Check for errors:"
echo "   :messages"
echo "   :checkhealth roslyn"
echo ""
echo "6. If still not working, check logs:"
echo "   cat ~/.local/state/nvim/lsp.log | grep -i roslyn"
echo ""
echo "======================================================================"
