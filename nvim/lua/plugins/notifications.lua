-- ============================================================================
-- Notifications Configuration
-- Make warnings and messages stay visible longer
-- ============================================================================

return {
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 5000, -- Duración en milisegundos (5 segundos, antes era ~2 segundos)
      render = "default", -- Estilo de notificación
      stages = "fade", -- Animación
      max_width = 80, -- Ancho máximo
      max_height = 20, -- Alto máximo
      on_open = function(win)
        -- Hacer que la ventana sea enfocable para poder scrollear
        vim.api.nvim_win_set_config(win, { focusable = true })
      end,
      top_down = false, -- Mostrar desde abajo hacia arriba
    },
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
      {
        "<leader>uN",
        "<cmd>Telescope notify<cr>",
        desc = "Show Notification History",
      },
    },
  },

  -- Telescope integration to see notification history
  {
    "telescope.nvim",
    optional = true,
    opts = function()
      require("telescope").load_extension("notify")
    end,
  },
}
