-- ============================================================================
-- Auto-save Configuration
-- Automatically save files when certain events occur
-- ============================================================================

return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true, -- Activar auto-save por defecto
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" }, -- Guardar al cambiar de buffer o perder foco
        defer_save = { "InsertLeave", "TextChanged" }, -- Guardar después de salir de insertar o cambiar texto
        cancel_deferred_save = { "InsertEnter" }, -- Cancelar guardado si vuelves a insertar
      },
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        -- No guardar si:
        if
          fn.getbufvar(buf, "&modifiable") == 1 -- El buffer es modificable
          and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) -- No está en lista de exclusión
        then
          return true -- Sí, guardar
        end
        return false -- No guardar
      end,
      write_all_buffers = false, -- Solo guardar el buffer actual
      debounce_delay = 1000, -- Esperar 1 segundo después del último cambio antes de guardar
    },
    keys = {
      {
        "<leader>ua",
        "<cmd>ASToggle<cr>",
        desc = "Toggle Auto-save",
      },
    },
  },
}
