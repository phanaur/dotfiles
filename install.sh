#!/bin/bash
# ============================================================================
# Dotfiles Installation Script
# Installs and links all configurations
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==================================================================="
echo "Dotfiles Installation"
echo "==================================================================="
echo ""

# ============================================================================
# 1. Install System Dependencies
# ============================================================================

log_info "Checking if setup-dev-env.sh should run..."

if [ -f "$DOTFILES_DIR/scripts/setup-dev-env.sh" ]; then
    read -p "Run full system setup (installs Neovim, Helix, language servers, etc.)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Running setup-dev-env.sh..."
        bash "$DOTFILES_DIR/scripts/setup-dev-env.sh"
    else
        log_warning "Skipping system setup. Make sure dependencies are installed manually."
    fi
else
    log_warning "setup-dev-env.sh not found. Skipping system setup."
fi

# ============================================================================
# 2. Backup Existing Configurations
# ============================================================================

log_info "Backing up existing configurations..."

backup_dir="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

if [ -d "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$backup_dir/nvim"
    log_success "Backed up existing Neovim config to $backup_dir/nvim"
fi

if [ -d "$HOME/.config/helix" ] || [ -L "$HOME/.config/helix" ]; then
    mv "$HOME/.config/helix" "$backup_dir/helix"
    log_success "Backed up existing Helix config to $backup_dir/helix"
fi

# ============================================================================
# 3. Create Symbolic Links
# ============================================================================

log_info "Creating symbolic links..."

mkdir -p "$HOME/.config"

# Neovim
if [ -d "$DOTFILES_DIR/nvim" ]; then
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    log_success "Linked Neovim config"
else
    log_warning "Neovim config directory not found in dotfiles"
fi

# Helix
if [ -d "$DOTFILES_DIR/helix" ]; then
    ln -sf "$DOTFILES_DIR/helix" "$HOME/.config/helix"
    log_success "Linked Helix config"
else
    log_warning "Helix config directory not found in dotfiles"
fi

# ============================================================================
# 4. Install Helix Grammars
# ============================================================================

log_info "Installing Helix tree-sitter grammars..."

if command -v hx &> /dev/null; then
    log_info "Fetching grammars (this may take a few minutes)..."
    hx --grammar fetch

    log_info "Building grammars (this may take several minutes)..."
    hx --grammar build

    log_success "Helix grammars installed"
else
    log_warning "Helix not found. Install it first or run setup-dev-env.sh"
fi

# ============================================================================
# 5. Setup Neovim Plugins
# ============================================================================

log_info "Setting up Neovim plugins..."

if command -v nvim &> /dev/null; then
    log_info "Syncing Neovim plugins (this may take a few minutes)..."

    # Create headless sync script
    cat > /tmp/lazy_sync.lua << 'EOF'
print("Starting Lazy plugin sync...")
vim.cmd("Lazy! sync")

-- Wait for sync to complete
vim.defer_fn(function()
  print("Lazy sync initiated. Waiting for completion...")

  -- Check every 2 seconds if sync is complete
  local function check_sync()
    local lazy_ok, lazy = pcall(require, "lazy")
    if lazy_ok then
      local plugins = lazy.plugins()
      local all_done = true

      for _, plugin in pairs(plugins) do
        if plugin._.updating or plugin._.cloning then
          all_done = false
          break
        end
      end

      if all_done then
        print("✓ Lazy sync complete!")
        vim.defer_fn(function()
          vim.cmd("qa!")
        end, 2000)
      else
        vim.defer_fn(check_sync, 2000)
      end
    else
      print("Lazy not available yet, retrying...")
      vim.defer_fn(check_sync, 2000)
    end
  end

  check_sync()

  -- Safety timeout: 5 minutes
  vim.defer_fn(function()
    print("⚠ Timeout reached. Some plugins may still be syncing.")
    vim.cmd("qa!")
  end, 300000)
end, 3000)
EOF

    echo ""
    echo "Syncing plugins in headless mode..."
    echo ""

    nvim --headless -c "luafile /tmp/lazy_sync.lua" 2>&1 &
    NVIM_PID=$!

    # Show progress indicator
    while kill -0 $NVIM_PID 2>/dev/null; do
      echo -n "."
      sleep 2
    done

    wait $NVIM_PID
    echo ""
    echo ""

    rm -f /tmp/lazy_sync.lua
    log_success "Neovim plugins synced"
else
    log_warning "Neovim not found. Install it first or run setup-dev-env.sh"
fi

# ============================================================================
# 6. Install AI Tools (Optional)
# ============================================================================

log_info "Checking AI tools..."

if ! command -v claude &> /dev/null; then
    read -p "Install Claude Code CLI for AI assistance in Neovim? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing Claude Code CLI..."
        if command -v npm &> /dev/null; then
            npm install -g @anthropic-ai/claude-code
            log_success "Claude Code CLI installed"
            log_warning "Remember to run 'claude login' to authenticate"
        else
            log_warning "npm not found. Install Node.js first or run setup-dev-env.sh"
        fi
    fi
else
    log_success "Claude Code CLI already installed: $(claude --version)"
fi

# ============================================================================
# 7. Copy Templates
# ============================================================================

log_info "Setting up templates..."

if [ -d "$DOTFILES_DIR/templates" ]; then
    # Copy to home directory for easy access
    cp "$DOTFILES_DIR/templates/.editorconfig.csharp" "$HOME/.editorconfig.csharp-template" 2>/dev/null && \
        log_success "Copied .editorconfig template to home directory" || \
        log_warning "Could not copy .editorconfig template"

    cp "$DOTFILES_DIR/templates/omnisharp.json" "$HOME/omnisharp.json.template" 2>/dev/null && \
        log_success "Copied omnisharp.json template to home directory" || \
        log_warning "Could not copy omnisharp.json template"
fi

# ============================================================================
# 8. Verification
# ============================================================================

echo ""
echo "==================================================================="
echo "Installation Complete!"
echo "==================================================================="
echo ""

log_success "Configuration installed successfully!"
echo ""
echo "Installed:"
if [ -L "$HOME/.config/nvim" ]; then
    echo "  ✓ Neovim config: ~/.config/nvim -> $DOTFILES_DIR/nvim"
else
    echo "  ✗ Neovim config not linked"
fi

if [ -L "$HOME/.config/helix" ]; then
    echo "  ✓ Helix config: ~/.config/helix -> $DOTFILES_DIR/helix"
else
    echo "  ✗ Helix config not linked"
fi

if command -v claude &> /dev/null; then
    echo "  ✓ Claude Code CLI: $(claude --version)"
else
    echo "  ✗ Claude Code CLI not installed"
fi

echo ""
echo "Backups (if any): $backup_dir"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
if command -v claude &> /dev/null; then
    echo "  2. Authenticate Claude Code: claude login"
    echo "  3. Open Neovim: nvim"
    echo "     - Test Claude Code: <leader>cc"
else
    echo "  2. Open Neovim: nvim"
fi
echo "     - Check :Mason for installed tools"
echo "     - Check :checkhealth for any issues"
if command -v hx &> /dev/null; then
    echo "  4. Open Helix: hx"
    echo "     - Grammars should be installed"
fi
echo "  5. For C# projects, copy templates:"
echo "     cp ~/.editorconfig.csharp-template <project>/.editorconfig"
echo "     cp ~/omnisharp.json.template <project>/omnisharp.json"
echo ""
echo "Documentation available in:"
echo "  - Dotfiles: $DOTFILES_DIR/docs/"
echo "  - AI Assistants: ~/.config/nvim/AI-ASSISTANTS.md"
echo ""

# Check for common issues
echo "Checking configuration..."
if [ ! -L "$HOME/.local/bin/omnisharp" ]; then
    log_warning "OmniSharp symlink not found. Run :Mason in Neovim to install it."
fi

if [ ! -d "$HOME/.config/helix/runtime/grammars" ]; then
    log_warning "Helix grammars not found. Run: hx --grammar fetch && hx --grammar build"
fi

if command -v claude &> /dev/null; then
    if ! claude --help &> /dev/null; then
        log_warning "Claude Code CLI may need authentication. Run: claude login"
    fi
fi

echo ""
log_success "Installation complete! Happy coding!"
echo ""
