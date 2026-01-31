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

# ============================================================================
# Distro Detection (for install hints)
# ============================================================================

detect_distro() {
    local distro=""
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "$ID" in
            fedora)                          distro="fedora" ;;
            ubuntu|debian|pop|linuxmint)     distro="ubuntu" ;;
            arch|manjaro|endeavouros|garuda)  distro="arch" ;;
            opensuse-tumbleweed|opensuse-leap|opensuse) distro="opensuse" ;;
            *)
                case "$ID_LIKE" in
                    *fedora*|*rhel*)   distro="fedora" ;;
                    *ubuntu*|*debian*) distro="ubuntu" ;;
                    *arch*)            distro="arch" ;;
                    *suse*)            distro="opensuse" ;;
                esac
                ;;
        esac
    fi
    if [ -z "$distro" ]; then
        if [ -f /etc/fedora-release ]; then distro="fedora"
        elif [ -f /etc/debian_version ]; then distro="ubuntu"
        elif [ -f /etc/arch-release ]; then distro="arch"
        elif [ -f /etc/SuSE-release ]; then distro="opensuse"
        else distro="unknown"
        fi
    fi
    echo "$distro"
}

get_install_hint() {
    local pkg="$1"
    local distro="$2"
    case "$pkg" in
        dotnet)
            case "$distro" in
                fedora)   echo "sudo dnf install dotnet-sdk-10.0" ;;
                ubuntu)   echo "sudo apt install dotnet-sdk-10.0 (requires Microsoft repo)" ;;
                arch)     echo "sudo pacman -S dotnet-sdk" ;;
                opensuse) echo "sudo zypper install dotnet-sdk-10.0 (requires Microsoft repo)" ;;
                *)        echo "Install .NET SDK from https://dotnet.microsoft.com" ;;
            esac ;;
        golang)
            case "$distro" in
                fedora)   echo "sudo dnf install golang" ;;
                ubuntu)   echo "sudo apt install golang-go" ;;
                arch)     echo "sudo pacman -S go" ;;
                opensuse) echo "sudo zypper install go" ;;
                *)        echo "Install Go from https://go.dev" ;;
            esac ;;
        nodejs)
            case "$distro" in
                fedora)   echo "sudo dnf install nodejs npm" ;;
                ubuntu)   echo "sudo apt install nodejs npm" ;;
                arch)     echo "sudo pacman -S nodejs npm" ;;
                opensuse) echo "sudo zypper install nodejs npm" ;;
                *)        echo "Install Node.js from https://nodejs.org" ;;
            esac ;;
        python)
            case "$distro" in
                fedora)   echo "sudo dnf install python3 python3-pip" ;;
                ubuntu)   echo "sudo apt install python3 python3-pip" ;;
                arch)     echo "sudo pacman -S python python-pip" ;;
                opensuse) echo "sudo zypper install python3 python3-pip" ;;
                *)        echo "Install Python from https://python.org" ;;
            esac ;;
        gcc)
            case "$distro" in
                fedora)   echo "sudo dnf install gcc gcc-c++" ;;
                ubuntu)   echo "sudo apt install gcc g++" ;;
                arch)     echo "sudo pacman -S gcc" ;;
                opensuse) echo "sudo zypper install gcc gcc-c++" ;;
                *)        echo "Install GCC via your package manager" ;;
            esac ;;
        clang)
            case "$distro" in
                fedora)   echo "sudo dnf install clang clang-tools-extra" ;;
                ubuntu)   echo "sudo apt install clang clang-tools" ;;
                arch)     echo "sudo pacman -S clang" ;;
                opensuse) echo "sudo zypper install clang clang-tools" ;;
                *)        echo "Install Clang via your package manager" ;;
            esac ;;
        clangd)
            case "$distro" in
                fedora)   echo "sudo dnf install clang-tools-extra" ;;
                ubuntu)   echo "sudo apt install clang-tools" ;;
                arch)     echo "sudo pacman -S clang" ;;
                opensuse) echo "sudo zypper install clang-tools" ;;
                *)        echo "Install clangd via your package manager" ;;
            esac ;;
        clang-format)
            case "$distro" in
                fedora)   echo "sudo dnf install clang-tools-extra" ;;
                ubuntu)   echo "sudo apt install clang-format" ;;
                arch)     echo "sudo pacman -S clang" ;;
                opensuse) echo "sudo zypper install clang-tools" ;;
                *)        echo "Install clang-format via your package manager" ;;
            esac ;;
    esac
}

DETECTED_DISTRO=$(detect_distro)

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

-- Use Lazy's sync API directly
vim.defer_fn(function()
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    print("✗ Failed to load Lazy")
    vim.cmd("qa!")
    return
  end

  print("✓ Lazy loaded, starting sync...")

  -- Use lazy.manage.sync() which is the proper API
  local manage_ok, manage = pcall(require, "lazy.manage")
  if manage_ok then
    -- Start sync
    manage.sync({
      wait = true,
      show = false,
    })

    print("✓ Lazy sync initiated")

    -- Monitor completion
    local function check_sync()
      local plugins = lazy.plugins()
      local still_working = false

      for _, plugin in pairs(plugins) do
        if plugin._.updating or plugin._.cloning or plugin._.building then
          still_working = true
          break
        end
      end

      if not still_working then
        print("✓ Lazy sync complete!")
        vim.defer_fn(function()
          vim.cmd("qa!")
        end, 2000)
      else
        vim.defer_fn(check_sync, 2000)
      end
    end

    vim.defer_fn(check_sync, 5000)
  else
    print("✗ Failed to load lazy.manage")
    vim.cmd("qa!")
  end

  -- Safety timeout: 5 minutes
  vim.defer_fn(function()
    print("⚠ Timeout reached. Forcing exit.")
    vim.cmd("qa!")
  end, 300000)
end, 1000)
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
        log_info "Downloading and running official installation script..."
        if curl -fsSL https://claude.ai/install.sh | bash; then
            # Reload shell to get claude in PATH
            export PATH="$HOME/.claude/bin:$PATH"
            if command -v claude &> /dev/null; then
                log_success "Claude Code CLI installed: $(claude --version)"
                log_warning "Remember to run 'claude login' to authenticate"
            else
                log_warning "Claude Code CLI installed but not in PATH yet."
                log_warning "Restart your terminal or run: export PATH=\"\$HOME/.claude/bin:\$PATH\""
            fi
        else
            log_warning "Failed to install Claude Code CLI."
            log_warning "Install manually with: curl -fsSL https://claude.ai/install.sh | bash"
        fi
    fi
else
    log_success "Claude Code CLI already installed: $(claude --version)"
fi

# ============================================================================
# 7. Install C# Tools (OmniSharp symlink, csharpier, netcoredbg)
# ============================================================================

log_info "Setting up C# development tools..."

mkdir -p "$HOME/.local/bin"

# OmniSharp symlink for Helix (Mason installs it for Neovim only)
OMNISHARP_MASON="$HOME/.local/share/nvim/mason/packages/omnisharp/OmniSharp"
if [ -f "$OMNISHARP_MASON" ]; then
    ln -sf "$OMNISHARP_MASON" "$HOME/.local/bin/omnisharp"
    log_success "OmniSharp symlinked to ~/.local/bin/omnisharp"
else
    log_warning "OmniSharp not found in Mason. Run :MasonInstall omnisharp in Neovim first, then re-run this script."
fi

# csharpier (C# formatter)
if command -v dotnet &> /dev/null; then
    if ! command -v dotnet-csharpier &> /dev/null && ! dotnet tool list -g 2>/dev/null | grep -q csharpier; then
        read -p "Install csharpier (C# formatter)? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            dotnet tool install -g csharpier && \
                log_success "csharpier installed" || \
                log_error "Failed to install csharpier"
        fi
    else
        log_success "csharpier already installed"
    fi

    # netcoredbg (.NET debugger)
    if ! command -v netcoredbg &> /dev/null; then
        read -p "Install netcoredbg (.NET debugger for Helix/Neovim)? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            log_info "Installing netcoredbg..."
            NETCOREDBG_VERSION="$(curl -fsSL https://api.github.com/repos/Samsung/netcoredbg/releases/latest | grep -Po '"tag_name": "\K[^"]+' 2>/dev/null || echo "3.1.3-1062")"
            log_info "Using netcoredbg version: $NETCOREDBG_VERSION"
            ARCH="$(uname -m)"
            case "$ARCH" in
                x86_64) NETCOREDBG_ARCH="linux-amd64" ;;
                aarch64) NETCOREDBG_ARCH="linux-arm64" ;;
                *) log_error "Unsupported architecture: $ARCH"; NETCOREDBG_ARCH="" ;;
            esac

            if [ -n "$NETCOREDBG_ARCH" ]; then
                NETCOREDBG_URL="https://github.com/Samsung/netcoredbg/releases/download/${NETCOREDBG_VERSION}/netcoredbg-${NETCOREDBG_ARCH}.tar.gz"
                NETCOREDBG_DIR="$HOME/.local/share/netcoredbg"
                mkdir -p "$NETCOREDBG_DIR"
                if curl -fsSL "$NETCOREDBG_URL" | tar xz -C "$NETCOREDBG_DIR" --strip-components=1; then
                    ln -sf "$NETCOREDBG_DIR/netcoredbg" "$HOME/.local/bin/netcoredbg"
                    log_success "netcoredbg installed to $NETCOREDBG_DIR"
                else
                    log_error "Failed to download netcoredbg. Install manually from https://github.com/Samsung/netcoredbg/releases"
                fi
            fi
        fi
    else
        log_success "netcoredbg already installed: $(netcoredbg --version 2>&1 | head -1)"
    fi
else
    log_warning ".NET SDK not found. Skipping C# tools installation."
fi

# ============================================================================
# 8. Copy Templates
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
# 9. Verification
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
echo ""

# --- Language tooling verification ---
log_info "Verifying language tools (required by Helix and Neovim)..."
echo ""

MISSING_TOOLS=0

check_tool() {
    local name="$1"
    local cmd="$2"
    local lang="$3"
    local fix="$4"
    if command -v "$cmd" &> /dev/null; then
        echo "  ✓ $name ($lang)"
    else
        log_warning "$name not found. $fix"
        MISSING_TOOLS=$((MISSING_TOOLS + 1))
    fi
}

echo "  SDKs and compilers:"
check_tool "dotnet" "dotnet" "C#" "Run: $(get_install_hint dotnet "$DETECTED_DISTRO")"
check_tool "go" "go" "Go" "Run: $(get_install_hint golang "$DETECTED_DISTRO")"
check_tool "rustc" "rustc" "Rust" "Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
check_tool "node" "node" "JS/TS" "Run: $(get_install_hint nodejs "$DETECTED_DISTRO")"
check_tool "python3" "python3" "Python" "Run: $(get_install_hint python "$DETECTED_DISTRO")"
check_tool "gcc" "gcc" "C/C++" "Run: $(get_install_hint gcc "$DETECTED_DISTRO")"
check_tool "clang" "clang" "C/C++" "Run: $(get_install_hint clang "$DETECTED_DISTRO")"
echo ""

echo "  Language servers:"
check_tool "omnisharp" "omnisharp" "C#" "Run: ./install.sh (section 7) or ln -sf ~/.local/share/nvim/mason/packages/omnisharp/OmniSharp ~/.local/bin/omnisharp"
check_tool "gopls" "gopls" "Go" "Run: go install golang.org/x/tools/gopls@latest"
check_tool "rust-analyzer" "rust-analyzer" "Rust" "Run: rustup component add rust-analyzer"
check_tool "pyright" "pyright-langserver" "Python" "Run: pip3 install --user pyright"
check_tool "ts-language-server" "typescript-language-server" "JS/TS" "Run: sudo npm install -g typescript-language-server"
check_tool "yaml-language-server" "yaml-language-server" "YAML" "Run: sudo npm install -g yaml-language-server"
check_tool "vscode-json-ls" "vscode-json-language-server" "JSON" "Run: sudo npm install -g vscode-langservers-extracted"
check_tool "taplo" "taplo" "TOML" "Run: cargo install taplo-cli --locked"
check_tool "marksman" "marksman" "Markdown" "Install from https://github.com/artempyanykh/marksman/releases"
check_tool "clangd" "clangd" "C/C++" "Run: $(get_install_hint clangd "$DETECTED_DISTRO")"
echo ""

echo "  Formatters:"
check_tool "csharpier" "csharpier" "C#" "Run: dotnet tool install -g csharpier"
check_tool "prettier" "prettier" "JS/TS/YAML/HTML/CSS/MD" "Run: sudo npm install -g prettier"
check_tool "black" "black" "Python" "Run: pip3 install --user black"
check_tool "rustfmt" "rustfmt" "Rust" "Run: rustup component add rustfmt"
check_tool "goimports" "goimports" "Go" "Run: go install golang.org/x/tools/cmd/goimports@latest"
check_tool "clang-format" "clang-format" "C/C++" "Run: $(get_install_hint clang-format "$DETECTED_DISTRO")"
echo ""

echo "  Debuggers:"
check_tool "netcoredbg" "netcoredbg" ".NET" "Re-run install.sh or download from https://github.com/Samsung/netcoredbg/releases"
check_tool "delve" "dlv" "Go" "Run: go install github.com/go-delve/delve/cmd/dlv@latest"
echo ""

if [ $MISSING_TOOLS -gt 0 ]; then
    log_warning "$MISSING_TOOLS tool(s) missing. Run scripts/setup-dev-env.sh for full installation."
else
    log_success "All language tools detected!"
fi

echo ""

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
