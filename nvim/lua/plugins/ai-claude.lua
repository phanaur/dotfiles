-- ============================================================================
-- Claude Code AI Integration
-- ============================================================================
--
-- Integración completa de Claude Code con Neovim
-- Requiere: Claude Code CLI instalado y autenticado
--
-- Instalación del CLI:
--   curl -fsSL https://claude.ai/install.sh | bash
--
-- NOTA: La instalación vía npm ya no está soportada.
--       Usa el script oficial de instalación.
--
-- Autenticación:
--   claude login
--
-- Keybindings:
--   <leader>cc - Toggle Claude terminal
--   <leader>cf - Focus Claude
--   <leader>cr - Resume última sesión
--   <leader>cC - Continue conversación
--   <leader>cm - Seleccionar modelo
--   <leader>cb - Añadir buffer actual al contexto
--   <leader>cs - Enviar selección visual a Claude
--
-- ============================================================================

return {
  "coder/claudecode.nvim",
  dependencies = {
    "folke/snacks.nvim", -- Terminal support
  },
  cmd = "ClaudeCode",
  keys = {
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
    { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer" },
    { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
  },
  opts = {
    -- Server Settings
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info", -- trace, debug, info, warn, error

    -- Terminal Display
    terminal = {
      split_side = "right", -- Panel a la derecha
      split_width_percentage = 0.35, -- 35% del ancho
      provider = "auto", -- auto, snacks, native, external, none
      auto_close = true,
      git_repo_cwd = true, -- Usar git root como working directory
    },

    -- Diff Handling (cuando Claude propone cambios)
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
    },
  },
  config = function(_, opts)
    require("claudecode").setup(opts)

    -- Mensajes de ayuda
    vim.api.nvim_create_user_command("ClaudeHelp", function()
      vim.notify(
        [[
Claude Code - Guía rápida:

<leader>cc - Abrir/cerrar Claude
<leader>cf - Focus en Claude
<leader>cb - Añadir archivo actual
<leader>cs - Enviar selección (visual mode)
<leader>cm - Cambiar modelo

Workflow:
1. Abre Claude con <leader>cc
2. Añade contexto con <leader>cb o <leader>cs
3. Escribe tu prompt en el terminal de Claude
4. Revisa y acepta cambios con :ClaudeCodeDiffAccept

Autenticación:
  claude login
]],
        vim.log.levels.INFO,
        { title = "Claude Code" }
      )
    end, { desc = "Show Claude help" })
  end,
}
