-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Cursor shape configuration for different modes
vim.opt.guicursor = {
  "n-c:block",           -- Normal, command: bloque █
  "i-ci-ve:ver25",       -- Insert: línea vertical (25% ancho) ┃
  "v:hor20",             -- Visual: subrayado (20% altura) ▁
  "r-cr:hor20",          -- Replace: subrayado (20% altura) ▁
  "o:hor50",             -- Operator: subrayado (50% altura)
  "a:blinkwait700-blinkoff400-blinkon250", -- Blinking settings
  "sm:block-blinkwait175-blinkoff150-blinkon175", -- Showmatch
}
