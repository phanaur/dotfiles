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
