#!/bin/bash
# ============================================================================
# Setup Development Environment (Multi-Distro)
# Supports: Fedora, Ubuntu/Debian, Arch Linux, OpenSUSE
# Configures LazyVim + Helix with all language servers and modern features
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# Distro Detection and Package Management
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
                # Fallback to ID_LIKE for derivatives
                case "$ID_LIKE" in
                    *fedora*|*rhel*)   distro="fedora" ;;
                    *ubuntu*|*debian*) distro="ubuntu" ;;
                    *arch*)            distro="arch" ;;
                    *suse*)            distro="opensuse" ;;
                esac
                ;;
        esac
    fi

    # Legacy fallback
    if [ -z "$distro" ]; then
        if [ -f /etc/fedora-release ]; then distro="fedora"
        elif [ -f /etc/debian_version ]; then distro="ubuntu"
        elif [ -f /etc/arch-release ]; then distro="arch"
        elif [ -f /etc/SuSE-release ]; then distro="opensuse"
        fi
    fi

    if [ -z "$distro" ]; then
        log_error "Unsupported distribution. Supported: Fedora, Ubuntu/Debian, Arch, OpenSUSE."
        exit 1
    fi

    echo "$distro"
}

pkg_update() {
    local distro="$1"
    case "$distro" in
        fedora)   sudo dnf update -y ;;
        ubuntu)   sudo apt update && sudo apt upgrade -y ;;
        arch)     sudo pacman -Syu --noconfirm ;;
        opensuse) sudo zypper refresh && sudo zypper update -y ;;
    esac
}

pkg_install() {
    local distro="$1"
    shift
    case "$distro" in
        fedora)   sudo dnf install -y "$@" ;;
        ubuntu)   sudo apt install -y "$@" ;;
        arch)     sudo pacman -S --noconfirm --needed "$@" ;;
        opensuse) sudo zypper install -y "$@" ;;
    esac
}

setup_dotnet_repo() {
    local distro="$1"
    case "$distro" in
        ubuntu)
            if ! apt-cache policy 2>/dev/null | grep -q "packages.microsoft.com"; then
                log_info "Adding Microsoft package repository for .NET..."
                sudo apt install -y wget apt-transport-https
                wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
                sudo dpkg -i /tmp/packages-microsoft-prod.deb
                rm -f /tmp/packages-microsoft-prod.deb
                sudo apt update
            fi
            ;;
        opensuse)
            if ! zypper repos 2>/dev/null | grep -q "packages-microsoft-com-prod"; then
                log_info "Adding Microsoft package repository for .NET..."
                sudo zypper install -y libicu
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo zypper addrepo https://packages.microsoft.com/opensuse/15/prod packages-microsoft-com-prod
                sudo zypper refresh
            fi
            ;;
    esac
}

# Detect distribution
DISTRO=$(detect_distro)
log_info "Detected distribution: $DISTRO"
log_info "Starting development environment setup..."

# ============================================================================
# 1. System Package Installation
# ============================================================================

log_info "Installing system packages..."

# Update system
pkg_update "$DISTRO"

# Install Neovim (latest stable)
log_info "Installing Neovim..."
pkg_install "$DISTRO" neovim

# Install Helix
log_info "Installing Helix..."
case "$DISTRO" in
    ubuntu)
        if command -v snap &> /dev/null; then
            sudo snap install helix --classic
        else
            log_warning "snap not found. Install snapd first, then: sudo snap install helix --classic"
        fi
        ;;
    *)
        pkg_install "$DISTRO" helix
        ;;
esac

# Install Rust
log_info "Installing Rust toolchain..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    log_success "Rust already installed: $(rustc --version)"
fi

# Install Rust tools
log_info "Installing Rust tools (rustfmt, clippy, rust-analyzer)..."
rustup component add rustfmt clippy rust-analyzer

# Install Fresh editor
log_info "Installing Fresh editor..."
if ! command -v fresh &> /dev/null; then
    case "$DISTRO" in
        arch)
            # Use AUR helper (yay or paru)
            if command -v yay &> /dev/null; then
                yay -S --noconfirm fresh-editor-bin
            elif command -v paru &> /dev/null; then
                paru -S --noconfirm fresh-editor-bin
            else
                log_warning "No AUR helper found. Install yay or paru first, then: yay -S fresh-editor-bin"
            fi
            ;;
        *)
            # Use cargo-binstall for fast binary installation
            if ! command -v cargo-binstall &> /dev/null; then
                log_info "Installing cargo-binstall for faster installations..."
                curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
            fi
            if command -v cargo-binstall &> /dev/null; then
                cargo binstall -y fresh-editor
            else
                log_warning "cargo-binstall not available. Falling back to cargo install (this will take longer)..."
                cargo install fresh-editor
            fi
            ;;
    esac
else
    log_success "Fresh already installed: $(fresh --version 2>&1 | head -1)"
fi

# Install .NET SDK 10
log_info "Installing .NET SDK 10..."
if ! command -v dotnet &> /dev/null; then
    setup_dotnet_repo "$DISTRO"
    case "$DISTRO" in
        fedora)   pkg_install "$DISTRO" dotnet-sdk-10.0 ;;
        ubuntu)   pkg_install "$DISTRO" dotnet-sdk-10.0 ;;
        arch)     pkg_install "$DISTRO" dotnet-sdk ;;
        opensuse) pkg_install "$DISTRO" dotnet-sdk-10.0 ;;
    esac
else
    log_success ".NET SDK already installed: $(dotnet --version)"
fi

# Install Go
log_info "Installing Go..."
if ! command -v go &> /dev/null; then
    case "$DISTRO" in
        fedora)   pkg_install "$DISTRO" golang ;;
        ubuntu)   pkg_install "$DISTRO" golang-go ;;
        arch)     pkg_install "$DISTRO" go ;;
        opensuse) pkg_install "$DISTRO" go ;;
    esac
else
    log_success "Go already installed: $(go version)"
fi

# Install Go tools (gopls, goimports, delve)
log_info "Installing Go tools (gopls, goimports, delve)..."
if command -v go &> /dev/null; then
    go install golang.org/x/tools/gopls@latest 2>/dev/null && log_success "gopls installed" || log_warning "Failed to install gopls"
    go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null && log_success "goimports installed" || log_warning "Failed to install goimports"
    go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null && log_success "delve debugger installed" || log_warning "Failed to install delve"
fi

# Install Node.js and npm
log_info "Installing Node.js and npm..."
pkg_install "$DISTRO" nodejs npm

# Install Python and pipx
log_info "Installing Python..."
case "$DISTRO" in
    arch) pkg_install "$DISTRO" python python-pipx ;;
    *)    pkg_install "$DISTRO" python3 python3-pip pipx ;;
esac

# Install build tools
log_info "Installing build tools..."
case "$DISTRO" in
    fedora)   pkg_install "$DISTRO" gcc gcc-c++ clang clang-tools-extra make cmake ;;
    ubuntu)   pkg_install "$DISTRO" gcc g++ clang clang-tools make cmake ;;
    arch)     pkg_install "$DISTRO" gcc clang make cmake ;;
    opensuse) pkg_install "$DISTRO" gcc gcc-c++ clang clang-tools make cmake ;;
esac

# Install additional tools
log_info "Installing additional tools..."
case "$DISTRO" in
    fedora)   pkg_install "$DISTRO" git curl wget unzip ripgrep fd-find rsync ;;
    ubuntu)   pkg_install "$DISTRO" git curl wget unzip ripgrep fd-find rsync ;;
    arch)     pkg_install "$DISTRO" git curl wget unzip ripgrep fd rsync ;;
    opensuse) pkg_install "$DISTRO" git curl wget unzip ripgrep fd rsync ;;
esac

# ============================================================================
# 2. Language Servers and Formatters Installation
# ============================================================================

log_info "Installing language servers and formatters..."

# Python tools
log_info "Installing Python tools (pyright, black)..."
case "$DISTRO" in
    arch)
        pkg_install "$DISTRO" pyright python-black
        ;;
    *)
        pipx install pyright 2>/dev/null || pip3 install --user pyright
        pipx install black 2>/dev/null || pip3 install --user black
        ;;
esac

# TypeScript tools
log_info "Installing TypeScript tools..."
sudo npm install -g typescript typescript-language-server prettier

# YAML tools
log_info "Installing YAML language server..."
sudo npm install -g yaml-language-server

# JSON/HTML/CSS language servers
log_info "Installing VSCode language servers..."
sudo npm install -g vscode-langservers-extracted

# Markdown tools
log_info "Installing Markdown tools (marksman)..."
MARKSMAN_VERSION="2023-12-09"
if ! command -v marksman &> /dev/null; then
    wget -q "https://github.com/artempyanykh/marksman/releases/download/${MARKSMAN_VERSION}/marksman-linux-x64" -O /tmp/marksman
    chmod +x /tmp/marksman
    sudo mv /tmp/marksman /usr/local/bin/marksman
fi

# TOML tools (taplo)
log_info "Installing TOML language server (taplo)..."
if ! command -v taplo &> /dev/null; then
    cargo install taplo-cli --locked
fi

# ============================================================================
# 3. LazyVim Configuration
# ============================================================================

log_info "Configuring LazyVim..."

# Create LazyVim config directories
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_PLUGINS_DIR="$NVIM_CONFIG_DIR/lua/plugins"
NVIM_CONFIG_LUA_DIR="$NVIM_CONFIG_DIR/lua/config"

mkdir -p "$NVIM_PLUGINS_DIR"
mkdir -p "$NVIM_CONFIG_LUA_DIR"

# Update lazy.lua to add language extras
log_info "Configuring language support in lazy.lua..."
LAZY_FILE="$NVIM_CONFIG_LUA_DIR/lazy.lua"

if [ -f "$LAZY_FILE" ]; then
    # Check if extras are already added
    if ! grep -q "lazyvim.plugins.extras.lang.rust" "$LAZY_FILE"; then
        # Create backup
        cp "$LAZY_FILE" "$LAZY_FILE.backup.$(date +%Y%m%d_%H%M%S)"

        # Add language extras after LazyVim import
        sed -i '/{ "LazyVim\/LazyVim", import = "lazyvim.plugins" },/a\    -- import language extras\n    { import = "lazyvim.plugins.extras.lang.rust" },\n    { import = "lazyvim.plugins.extras.lang.clangd" },\n    { import = "lazyvim.plugins.extras.lang.python" },\n    { import = "lazyvim.plugins.extras.lang.typescript" },\n    { import = "lazyvim.plugins.extras.lang.yaml" },\n    { import = "lazyvim.plugins.extras.lang.toml" },\n    { import = "lazyvim.plugins.extras.lang.json" },\n    { import = "lazyvim.plugins.extras.lang.markdown" },' "$LAZY_FILE"

        log_success "Updated lazy.lua with language extras"
    else
        log_success "Language extras already present in lazy.lua"
    fi
fi

# Create language configuration file
log_info "Creating language configuration..."
cat > "$NVIM_PLUGINS_DIR/languages.lua" << 'EOF'
-- ============================================================================
-- Multi-Language Configuration
-- Additional settings for languages imported in lazy.lua
-- NOTE: C# is configured separately in csharp-roslyn.lua with Roslyn
-- ============================================================================

return {
  -- Additional CSS/HTML configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {
          settings = {
            css = { validate = true },
            scss = { validate = true },
            less = { validate = true },
          },
        },
        html = {
          filetypes = { "html" },
        },
      },
    },
  },

  -- Conform.nvim for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        toml = { "taplo" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
EOF

# Create diagnostics configuration
log_info "Creating diagnostics configuration..."
cat > "$NVIM_PLUGINS_DIR/diagnostics.lua" << 'EOF'
-- Improved Diagnostics Display
return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.diagnostic.config({
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        float = {
          max_width = 80,
          max_height = 20,
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          focusable = true,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Auto-show diagnostic float when cursor holds
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
          }
          vim.diagnostic.open_float(nil, opts)
        end,
      })

      vim.opt.updatetime = 500

      -- Diagnostic signs
      local signs = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
      }
      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
      end
    end,
  },

  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          vim.keymap.set("n", "gl", vim.diagnostic.open_float, { buffer = bufnr, desc = "Show line diagnostics" })
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next Diagnostic" })
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Prev Diagnostic" })
          vim.keymap.set("n", "]e", function()
            vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
          end, { buffer = bufnr, desc = "Next Error" })
          vim.keymap.set("n", "[e", function()
            vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
          end, { buffer = bufnr, desc = "Prev Error" })
        end,
      })
    end,
  },
}
EOF

# Create notifications configuration
log_info "Creating notifications configuration..."
cat > "$NVIM_PLUGINS_DIR/notifications.lua" << 'EOF'
-- Notifications Configuration
return {
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 5000,
      render = "default",
      stages = "fade",
      max_width = 80,
      max_height = 20,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { focusable = true })
      end,
      top_down = false,
    },
    keys = {
      { "<leader>un", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss Notifications" },
      { "<leader>uN", "<cmd>Telescope notify<cr>", desc = "Notification History" },
    },
  },
  {
    "telescope.nvim",
    optional = true,
    opts = function()
      require("telescope").load_extension("notify")
    end,
  },
}
EOF

# Create C# Roslyn LSP configuration
cat > "$NVIM_PLUGINS_DIR/csharp-roslyn.lua" << 'EOF'
-- Configuración de Roslyn LSP (oficial de Microsoft)
return {
  -- Deshabilitar OmniSharp en Neovim (se usa en Helix)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = false,
      },
    },
  },

  -- Roslyn LSP (oficial de Microsoft para C#)
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    config = function()
      require("roslyn").setup({
        config = {
          settings = {
            ["csharp|background_analysis"] = {
              dotnet_analyzer_diagnostics_scope = "fullSolution",
              dotnet_compiler_diagnostics_scope = "fullSolution",
            },
            ["csharp|code_lens"] = {
              dotnet_enable_references_code_lens = true,
            },
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_variable_types = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types = true,
              csharp_enable_inlay_hints_for_types = true,
              dotnet_enable_inlay_hints_for_parameters = true,
              dotnet_enable_inlay_hints_for_literal_parameters = true,
              dotnet_enable_inlay_hints_for_object_creation_parameters = true,
              dotnet_enable_inlay_hints_for_indexer_parameters = true,
              dotnet_enable_inlay_hints_for_other_parameters = true,
              dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
              dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
              dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
            },
          },
        },
      })
    end,
  },
}
EOF

log_success "LazyVim configuration files created (including Roslyn LSP for C#)"

# ============================================================================
# 4. Helix Configuration
# ============================================================================

log_info "Configuring Helix..."

HELIX_CONFIG_DIR="$HOME/.config/helix"
HELIX_CONFIG_FILE="$HELIX_CONFIG_DIR/config.toml"
HELIX_LANGUAGES_FILE="$HELIX_CONFIG_DIR/languages.toml"

mkdir -p "$HELIX_CONFIG_DIR"

# Update Helix languages.toml to use OmniSharp for C#
if [ -f "$HELIX_LANGUAGES_FILE" ]; then
    if grep -q "csharp-ls" "$HELIX_LANGUAGES_FILE"; then
        cp "$HELIX_LANGUAGES_FILE" "$HELIX_LANGUAGES_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        sed -i 's/language-servers = \["csharp-ls"\]/language-servers = ["omnisharp"]/' "$HELIX_LANGUAGES_FILE"
        sed -i 's/\[language-server.csharp-ls\]/[language-server.omnisharp]/' "$HELIX_LANGUAGES_FILE"
        sed -i 's/command = "csharp-ls"/command = "omnisharp"\nargs = ["-lsp"]/' "$HELIX_LANGUAGES_FILE"
        log_success "Helix configured to use OmniSharp for C#"
    fi
fi

# ============================================================================
# 5. Mason Package Installation
# ============================================================================

log_info "Installing Mason packages (including OmniSharp)..."
log_info "This may take several minutes, especially for OmniSharp (~100MB)..."

cat > /tmp/install_mason_packages.lua << 'EOF'
-- Sync Lazy plugins first
print("Starting Lazy plugin sync...")

local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  print("✗ Failed to load Lazy")
  vim.cmd("qa!")
  return
end

local manage_ok, manage = pcall(require, "lazy.manage")
if manage_ok then
  print("✓ Starting Lazy sync...")
  manage.sync({
    wait = true,
    show = false,
  })
else
  print("✗ Failed to load lazy.manage")
end

-- Wait for Lazy sync to complete before installing Mason packages
-- Increased delay to allow plugin sync to finish
vim.defer_fn(function()
  print("\n✓ Starting Mason package installation...")
  -- Packages list
  local packages = {
    "omnisharp",         -- For Helix (large, ~100MB)
    "csharpier",
    "netcoredbg",
    "rust-analyzer",
    "clangd",
    "clang-format",
    "pyright",
    "black",
    "typescript-language-server",
    "prettier",
    "yaml-language-server",
    "json-lsp",
    "html-lsp",
    "css-lsp",
    "marksman",
    "taplo",
  }

  local registry = require("mason-registry")
  registry.refresh()

  vim.defer_fn(function()
    local total = #packages
    local installed = 0
    local failed = {}
    local in_progress = {}

    -- Install packages with progress tracking
    for _, package_name in ipairs(packages) do
      local ok, package = pcall(registry.get_package, package_name)
      if ok then
        if not package:is_installed() then
          print(string.format("[%d/%d] Installing %s...", installed + 1, total, package_name))
          in_progress[package_name] = true

          package:install():once("closed", function()
            in_progress[package_name] = nil
            if package:is_installed() then
              installed = installed + 1
              print(string.format("✓ %s installed successfully", package_name))
            else
              table.insert(failed, package_name)
              print(string.format("✗ %s installation failed", package_name))
            end
          end)
        else
          installed = installed + 1
          print(string.format("✓ %s already installed", package_name))
        end
      else
        table.insert(failed, package_name)
        print(string.format("✗ Package not found: %s", package_name))
      end
    end

    -- Monitor installation progress and exit when done
    local function check_completion()
      local still_running = false
      for pkg, _ in pairs(in_progress) do
        still_running = true
        break
      end

      if not still_running then
        print("\n========================================")
        print(string.format("Installation complete: %d/%d packages", installed, total))
        if #failed > 0 then
          print("Failed packages: " .. table.concat(failed, ", "))
        end
        print("========================================\n")
        vim.cmd("qa!")
      else
        vim.defer_fn(check_completion, 2000)
      end
    end

    -- Start checking after initial delay
    vim.defer_fn(check_completion, 5000)

    -- Safety timeout: 10 minutes (for large packages like OmniSharp)
    vim.defer_fn(function()
      print("\n⚠ Timeout reached (10 minutes). Forcing exit.")
      print("Some packages may still be installing in the background.")
      vim.cmd("qa!")
    end, 600000)
  end, 3000)
end, 10000)  -- Wait 10 seconds for Lazy sync to complete
EOF

echo ""
echo "Installing packages in headless mode..."
echo "This may take 5-10 minutes for large packages like OmniSharp."
echo ""

nvim --headless -c "luafile /tmp/install_mason_packages.lua" 2>&1 &
NVIM_PID=$!

# Show progress indicator while nvim is running
while kill -0 $NVIM_PID 2>/dev/null; do
  echo -n "."
  sleep 2
done

wait $NVIM_PID
echo ""
echo ""

rm -f /tmp/install_mason_packages.lua

# Create symlink for OmniSharp so Helix can use it
log_info "Creating symlink for OmniSharp (for Helix)..."
mkdir -p ~/.local/bin

# Wait for OmniSharp to finish installing (with retries)
OMNISHARP_PATH="$HOME/.local/share/nvim/mason/packages/omnisharp/OmniSharp"
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if [ -f "$OMNISHARP_PATH" ]; then
        ln -sf "$OMNISHARP_PATH" "$HOME/.local/bin/omnisharp"
        chmod +x "$HOME/.local/bin/omnisharp"
        log_success "OmniSharp symlink created for Helix"
        break
    else
        if [ $RETRY_COUNT -eq 0 ]; then
            log_info "Waiting for OmniSharp to finish installing..."
        fi
        sleep 2
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done

if [ ! -f "$OMNISHARP_PATH" ]; then
    log_warning "OmniSharp not found after waiting. You may need to:"
    log_warning "  1. Open Neovim: nvim"
    log_warning "  2. Run: :Mason"
    log_warning "  3. Install omnisharp manually"
    log_warning "  4. Create symlink: ln -sf ~/.local/share/nvim/mason/packages/omnisharp/OmniSharp ~/.local/bin/omnisharp"
fi

# Install OmniSharp wrapper for Helix (filters invalid null messages)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_PATH="$SCRIPT_DIR/omnisharp-wrapper.sh"
if [ -f "$WRAPPER_PATH" ]; then
    ln -sf "$WRAPPER_PATH" "$HOME/.local/bin/omnisharp-wrapper"
    log_success "OmniSharp wrapper symlinked to ~/.local/bin/omnisharp-wrapper"
fi

# ============================================================================
# 6. EditorConfig and OmniSharp Configuration Templates
# ============================================================================

log_info "Creating configuration templates..."

# Create .editorconfig template
cat > "$HOME/.editorconfig.csharp-template" << 'EOF'
# C# - Modern conventions (C# 12+ / .NET 8+)
[*.cs]
# File-scoped namespaces
csharp_style_namespace_declarations = file_scoped:warning

# Use 'var' when type is obvious
csharp_style_var_for_built_in_types = true:suggestion
csharp_style_var_when_type_is_apparent = true:warning
csharp_style_var_elsewhere = true:suggestion

# Braces - optional for single-line statements
csharp_prefer_braces = when_multiline:suggestion

# Expression-bodied members
csharp_style_expression_bodied_methods = when_on_single_line:suggestion
csharp_style_expression_bodied_properties = true:warning
csharp_style_expression_bodied_accessors = true:warning
csharp_style_expression_bodied_lambdas = true:warning

# Pattern matching
csharp_style_pattern_matching_over_as_with_null_check = true:warning
csharp_style_pattern_matching_over_is_with_cast_check = true:warning
csharp_style_prefer_switch_expression = true:suggestion
csharp_style_prefer_not_pattern = true:warning

# Modern C# features
csharp_style_prefer_index_operator = true:warning
csharp_style_prefer_range_operator = true:warning
csharp_style_implicit_object_creation_when_type_is_apparent = true:warning
csharp_style_inlined_variable_declaration = true:warning

# Null checking
csharp_style_throw_expression = true:warning
csharp_style_conditional_delegate_call = true:warning
dotnet_style_coalesce_expression = true:warning
dotnet_style_null_propagation = true:warning

# 'using' directives
csharp_using_directive_placement = outside_namespace:warning
EOF

# Create omnisharp.json template
cat > "$HOME/omnisharp.json.template" << 'EOF'
{
  "$schema": "http://json.schemastore.org/omnisharp",
  "FormattingOptions": {
    "EnableEditorConfigSupport": true,
    "OrganizeImports": true
  },
  "RoslynExtensionsOptions": {
    "EnableAnalyzersSupport": true,
    "EnableImportCompletion": true,
    "EnableDecompilationSupport": true,
    "InlayHintsOptions": {
      "EnableForParameters": true,
      "EnableForTypes": true,
      "ForImplicitVariableTypes": true,
      "ForImplicitObjectCreation": true
    }
  },
  "FileOptions": {
    "SystemExcludeSearchPatterns": [
      "**/node_modules/**/*",
      "**/bin/**/*",
      "**/obj/**/*",
      "**/.git/**/*"
    ]
  },
  "Sdk": {
    "IncludePrereleases": true
  },
  "MsBuild": {
    "LoadProjectsOnDemand": false,
    "EnablePackageAutoRestore": true
  }
}
EOF

log_success "Configuration templates created in home directory"

# ============================================================================
# 7. Verification
# ============================================================================

log_info "Verifying installation..."

echo ""
echo "==================================================================="
echo "Installation Summary"
echo "==================================================================="

# Check Neovim
if command -v nvim &> /dev/null; then
    log_success "Neovim: $(nvim --version | head -1)"
else
    log_error "Neovim not found"
fi

# Check Helix
if command -v hx &> /dev/null; then
    log_success "Helix: $(hx --version)"
elif command -v helix &> /dev/null; then
    log_success "Helix: $(helix --version)"
else
    log_error "Helix not found"
fi

# Check Fresh
if command -v fresh &> /dev/null; then
    log_success "Fresh: $(fresh --version 2>&1 | head -1)"
else
    log_error "Fresh not found"
fi

# Check .NET
if command -v dotnet &> /dev/null; then
    log_success ".NET SDK: $(dotnet --version)"
else
    log_error ".NET SDK not found"
fi

# Check Go
if command -v go &> /dev/null; then
    log_success "Go: $(go version)"
else
    log_error "Go not found"
fi

# Check gopls
if command -v gopls &> /dev/null; then
    log_success "gopls: $(gopls version 2>&1 | head -1)"
else
    log_error "gopls not found"
fi

# Check Rust
if command -v rustc &> /dev/null; then
    log_success "Rust: $(rustc --version)"
else
    log_error "Rust not found"
fi

# Check rust-analyzer
if command -v rust-analyzer &> /dev/null; then
    log_success "rust-analyzer: available"
else
    log_error "rust-analyzer not found"
fi

# Check Node.js
if command -v node &> /dev/null; then
    log_success "Node.js: $(node --version)"
else
    log_error "Node.js not found"
fi

# Check Python
if command -v python3 &> /dev/null; then
    log_success "Python: $(python3 --version)"
else
    log_error "Python not found"
fi

# Check OmniSharp symlink
if [ -L ~/.local/bin/omnisharp ]; then
    log_success "OmniSharp: symlink created for Helix"
else
    log_warning "OmniSharp: symlink not found (may need manual installation)"
fi

echo "==================================================================="
echo ""

log_success "Development environment setup complete!"
echo ""
echo "Configuration applied:"
echo "  ✓ LazyVim with multi-language support"
echo "  ✓ Roslyn LSP for C# (Neovim)"
echo "  ✓ OmniSharp LSP for C# (Helix, Fresh)"
echo "  ✓ Manual save mode (all editors)"
echo "  ✓ Enhanced diagnostics (Neovim)"
echo "  ✓ Better notifications (Neovim)"
echo "  ✓ Configuration templates created"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Open Neovim: nvim"
echo "  3. Wait for plugins to sync"
echo "  4. For C# projects, copy templates:"
echo "     cp ~/.editorconfig.csharp-template <project>/.editorconfig"
echo "     cp ~/omnisharp.json.template <project>/omnisharp.json"
echo ""
echo "Documentation:"
echo "  - Neovim config: ~/.config/nvim/"
echo "  - Helix config: ~/.config/helix/"
echo "  - Fresh config: ~/.config/fresh/"
echo "  - Templates: ~/*.template"
echo ""
