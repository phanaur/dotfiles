-- ============================================================================
-- Google Gemini AI Integration
-- ============================================================================
--
-- NOTA: Este plugin está deshabilitado temporalmente debido a problemas
-- de dependencias en gemini-cli. Usa Claude Code (<leader>cc) mientras tanto.
--
-- Para habilitar más adelante:
-- 1. Resolver dependencias de gemini-cli:
--    pip install gemini-cli (actualmente tiene conflictos)
-- 2. Cambiar enabled = false a enabled = true
-- 3. Configurar API Key:
--    export GOOGLE_API_KEY="tu-api-key"
--
-- Alternativa: Usa Claude Code que funciona perfectamente
--
-- Keybindings (cuando esté habilitado):
--   <leader>mm - Toggle Gemini terminal
--   <leader>ma - Ask Gemini (normal o visual)
--   <leader>mf - Añadir archivo actual al contexto
--   <leader>mh - Health check del plugin
--   <leader>md - Enviar diagnósticos del buffer actual
--   <leader>mx - Fix errores automáticamente
--
-- NOTA: Cambiados de <leader>g a <leader>m para evitar conflicto con Git
--
-- ============================================================================

return {
  "marcinjahn/gemini-cli.nvim",
  enabled = false, -- Deshabilitado temporalmente por problemas de dependencias
  dependencies = {
    "folke/snacks.nvim", -- Terminal support
  },
  cmd = "Gemini",
  keys = {
    { "<leader>mm", "<cmd>Gemini toggle<cr>", desc = "Toggle Gemini CLI" },
    { "<leader>ma", "<cmd>Gemini ask<cr>", desc = "Ask Gemini", mode = { "n", "v" } },
    { "<leader>mf", "<cmd>Gemini add_file<cr>", desc = "Add File" },
    { "<leader>mh", "<cmd>Gemini health<cr>", desc = "Health Check" },
    { "<leader>md", "<cmd>Gemini add_diagnostics<cr>", desc = "Add Diagnostics" },
  },
  opts = {
    -- Comando de Gemini CLI
    gemini_cmd = "gemini",
    args = {},

    -- Auto-reload terminal al enviar comandos
    auto_reload = false,

    -- Configuración del picker (para seleccionar archivos)
    picker_cfg = {
      preset = "vscode", -- o "default"
    },

    -- Configuración del terminal
    win = {
      wo = {
        winbar = " Gemini CLI", -- Título de la ventana
      },
      style = "gemini_cli",
      position = "right", -- right, left, bottom, top
      relative = "editor",
    },

    -- Configuración de Gemini CLI
    config = {
      os = {
        editPreset = "nvim-remote", -- Integración con Neovim
      },
      gui = {
        nerdFontsVersion = "3", -- Para iconos
      },
    },
  },
  config = function(_, opts)
    require("gemini_cli").setup(opts)

    -- Comando de ayuda personalizado
    vim.api.nvim_create_user_command("GeminiHelp", function()
      vim.notify(
        [[
Google Gemini CLI - Guía rápida:

<leader>mm - Abrir/cerrar Gemini
<leader>ma - Preguntar a Gemini
<leader>mf - Añadir archivo actual
<leader>md - Enviar diagnósticos (errores/warnings)
<leader>mh - Verificar estado del plugin
<leader>mx - Fix errores automáticamente

Workflow:
1. Abre Gemini con <leader>mm
2. Añade contexto con <leader>mf
3. Pregunta con <leader>ma o escribe directamente
4. Envía errores con <leader>md para que los analice

Uso interactivo:
  :Gemini send "tu pregunta"
  :Gemini add_file /ruta/al/archivo

Configuración de API Key:
  export GOOGLE_API_KEY="tu-api-key"

Obtener API Key:
  https://makersuite.google.com/app/apikey

NOTA: Keybindings cambiados de <leader>g a <leader>m
      para evitar conflicto con comandos de Git
]],
        vim.log.levels.INFO,
        { title = "Gemini CLI" }
      )
    end, { desc = "Show Gemini help" })

    -- Atajo para enviar diagnósticos automáticamente
    vim.api.nvim_create_user_command("GeminiFixErrors", function()
      local api = require("gemini_cli").api
      api.toggle_terminal()
      vim.defer_fn(function()
        api.send_to_terminal("@diagnostics")
        api.send_to_terminal("Analiza los errores y proporciona soluciones específicas para cada uno.")
      end, 500)
    end, { desc = "Ask Gemini to fix errors" })

    -- Keybinding adicional para fix rápido de errores
    vim.keymap.set("n", "<leader>mx", ":GeminiFixErrors<cr>", { desc = "Fix Errors with Gemini" })
  end,
}
