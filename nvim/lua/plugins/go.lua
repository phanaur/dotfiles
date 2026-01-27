-- ============================================================================
-- Go Language Configuration
-- ============================================================================

return {
  -- Configure gopls (Go Language Server)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                shadow = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
    },
  },

  -- Go-specific tools and features
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      require("go").setup({
        -- Disable lsp_cfg as we're using nvim-lspconfig directly
        lsp_cfg = false,
        lsp_keymaps = false,
        lsp_codelens = true,
        diagnostic = {
          hdlr = false, -- Use nvim's built-in diagnostic handler
          underline = true,
          virtual_text = { spacing = 4, prefix = "●" },
          signs = true,
          update_in_insert = false,
        },
        lsp_inlay_hints = {
          enable = true,
          style = "inlay",
        },
        trouble = true,
        luasnip = true,
      })

      -- Auto commands for Go
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimport()
        end,
        group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
      })
    end,
    keys = {
      { "<leader>gj", "<cmd>GoAddTag json<cr>", desc = "Add json tags" },
      { "<leader>gy", "<cmd>GoAddTag yaml<cr>", desc = "Add yaml tags" },
      { "<leader>gr", "<cmd>GoRmTag<cr>", desc = "Remove tags" },
      { "<leader>gf", "<cmd>GoFillStruct<cr>", desc = "Fill struct" },
      { "<leader>gi", "<cmd>GoIfErr<cr>", desc = "Add if err" },
      { "<leader>gt", "<cmd>GoTest<cr>", desc = "Run test" },
      { "<leader>gT", "<cmd>GoTestFunc<cr>", desc = "Run test for current func" },
      { "<leader>gc", "<cmd>GoCoverage<cr>", desc = "Show coverage" },
    },
  },
}
