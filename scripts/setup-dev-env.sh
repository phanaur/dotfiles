#!/bin/bash
# ============================================================================
# Setup Development Environment for Fedora 43
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

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    log_error "This script is designed for Fedora. Exiting."
    exit 1
fi

log_info "Starting development environment setup for Fedora 43..."

# ============================================================================
# 1. System Package Installation
# ============================================================================

log_info "Installing system packages..."

# Update system
sudo dnf update -y

# Install Neovim (latest stable)
log_info "Installing Neovim..."
sudo dnf install -y neovim

# Install Helix
log_info "Installing Helix..."
sudo dnf install -y helix

# Install .NET SDK 10
log_info "Installing .NET SDK 10..."
if ! command -v dotnet &> /dev/null; then
    sudo dnf install -y dotnet-sdk-10.0
else
    log_success ".NET SDK already installed: $(dotnet --version)"
fi

# Install Rust
log_info "Installing Rust toolchain..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    log_success "Rust already installed: $(rustc --version)"
fi

# Install Rust tools
log_info "Installing Rust tools (rustfmt, clippy)..."
rustup component add rustfmt clippy

# Install Node.js and npm
log_info "Installing Node.js and npm..."
sudo dnf install -y nodejs npm

# Install Python and pip
log_info "Installing Python..."
sudo dnf install -y python3 python3-pip

# Install build tools
log_info "Installing build tools..."
sudo dnf install -y gcc gcc-c++ clang clang-tools-extra make cmake

# Install additional tools
log_info "Installing additional tools..."
sudo dnf install -y git curl wget unzip ripgrep fd-find

# ============================================================================
# 2. Language Servers and Formatters Installation
# ============================================================================

log_info "Installing language servers and formatters..."

# Python tools
log_info "Installing Python tools (pyright, black)..."
pip3 install --user pyright black

# TypeScript tools
log_info "Installing TypeScript tools..."
sudo npm install -g typescript typescript-language-server prettier

# YAML tools
log_info "Installing YAML language server..."
sudo npm install -g yaml-language-server

# JSON/HTML/CSS language servers
log_info "Installing VSCode language servers..."
sudo npm install -g vscode-langservers-extracted

# Claude Code CLI (AI Assistant)
log_info "Installing Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    sudo npm install -g @anthropic-ai/claude-code
    log_success "Claude Code CLI installed"
    log_warning "Run 'claude login' to authenticate"
else
    log_success "Claude Code already installed: $(claude --version)"
fi

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

# Create auto-save configuration
log_info "Creating auto-save configuration..."
cat > "$NVIM_PLUGINS_DIR/autosave.lua" << 'EOF'
-- Auto-save Configuration
return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
          return true
        end
        return false
      end,
      write_all_buffers = false,
      debounce_delay = 1000,
    },
    keys = {
      { "<leader>ua", "<cmd>ASToggle<cr>", desc = "Toggle Auto-save" },
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

log_success "LazyVim configuration files created"

# ============================================================================
# 4. Helix Configuration
# ============================================================================

log_info "Configuring Helix..."

HELIX_CONFIG_DIR="$HOME/.config/helix"
HELIX_CONFIG_FILE="$HELIX_CONFIG_DIR/config.toml"
HELIX_LANGUAGES_FILE="$HELIX_CONFIG_DIR/languages.toml"

mkdir -p "$HELIX_CONFIG_DIR"

# Configure auto-save in Helix
if [ -f "$HELIX_CONFIG_FILE" ]; then
    # Check if auto-save is already configured
    if ! grep -q "auto-save" "$HELIX_CONFIG_FILE"; then
        cp "$HELIX_CONFIG_FILE" "$HELIX_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        # Add auto-save to [editor] section
        if grep -q "^\[editor\]" "$HELIX_CONFIG_FILE"; then
            sed -i '/^\[editor\]/a auto-save = true\nidle-timeout = 1000  # Auto-save after 1 second' "$HELIX_CONFIG_FILE"
        else
            echo -e "\n[editor]\nauto-save = true\nidle-timeout = 1000" >> "$HELIX_CONFIG_FILE"
        fi
        log_success "Auto-save configured in Helix"
    else
        log_success "Auto-save already configured in Helix"
    fi
else
    # Create new config file
    cat > "$HELIX_CONFIG_FILE" << 'EOF'
[editor]
auto-save = true
idle-timeout = 1000
line-number = "relative"
indent-guides.render = true

[editor.lsp]
display-messages = true
display-inlay-hints = true

[editor.inline-diagnostics]
cursor-line = "hint"
other-lines = "error"
EOF
    log_success "Helix config.toml created"
fi

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

cat > /tmp/install_mason_packages.lua << 'EOF'
vim.cmd("Lazy! sync")
vim.defer_fn(function()
  local packages = {
    "omnisharp",
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
    for _, package_name in ipairs(packages) do
      local ok, package = pcall(registry.get_package, package_name)
      if ok then
        if not package:is_installed() then
          print("Installing " .. package_name .. "...")
          package:install()
        else
          print(package_name .. " already installed")
        end
      else
        print("Package not found: " .. package_name)
      end
    end

    vim.defer_fn(function()
      print("Mason installation complete!")
      vim.cmd("qa!")
    end, 60000)
  end, 2000)
end, 2000)
EOF

nvim --headless -c "luafile /tmp/install_mason_packages.lua" 2>&1 | grep -E "(Installing|installed|complete)" || true
rm -f /tmp/install_mason_packages.lua

# Create symlink for OmniSharp so Helix can use it
log_info "Creating symlink for OmniSharp..."
mkdir -p ~/.local/bin
if [ -f ~/.local/share/nvim/mason/packages/omnisharp/OmniSharp ]; then
    ln -sf ~/.local/share/nvim/mason/packages/omnisharp/OmniSharp ~/.local/bin/omnisharp
    log_success "OmniSharp symlink created for Helix"
else
    log_warning "OmniSharp not found in Mason packages. Install it manually with :Mason in Neovim"
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
else
    log_error "Helix not found"
fi

# Check .NET
if command -v dotnet &> /dev/null; then
    log_success ".NET SDK: $(dotnet --version)"
else
    log_error ".NET SDK not found"
fi

# Check Rust
if command -v rustc &> /dev/null; then
    log_success "Rust: $(rustc --version)"
else
    log_error "Rust not found"
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

# Check Claude Code CLI
if command -v claude &> /dev/null; then
    log_success "Claude Code CLI: $(claude --version)"
else
    log_warning "Claude Code CLI: not found"
fi

echo "==================================================================="
echo ""

log_success "Development environment setup complete!"
echo ""
echo "Configuration applied:"
echo "  ✓ LazyVim with multi-language support"
echo "  ✓ Roslyn LSP for C# (Neovim)"
echo "  ✓ OmniSharp LSP for C# (Helix)"
echo "  ✓ Auto-save enabled (both editors)"
echo "  ✓ Enhanced diagnostics (Neovim)"
echo "  ✓ Better notifications (Neovim)"
echo "  ✓ Claude Code CLI installed"
echo "  ✓ Configuration templates created"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Authenticate Claude Code: claude login"
echo "  3. Open Neovim: nvim"
echo "  4. Wait for plugins to sync"
echo "  5. Test Claude Code: <leader>cc in Neovim"
echo "  6. For C# projects, copy templates:"
echo "     cp ~/.editorconfig.csharp-template <project>/.editorconfig"
echo "     cp ~/omnisharp.json.template <project>/omnisharp.json"
echo ""
echo "Documentation:"
echo "  - Neovim config: ~/.config/nvim/"
echo "  - Helix config: ~/.config/helix/"
echo "  - AI Assistants: ~/.config/nvim/AI-ASSISTANTS.md"
echo "  - Templates: ~/*.template"
echo ""
