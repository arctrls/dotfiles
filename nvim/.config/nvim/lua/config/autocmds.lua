-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Remove LazyVim's spell check autocmd
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Force disable spell check on all file types
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "FileType"}, {
  pattern = "*",
  callback = function()
    vim.opt_local.spell = false
  end,
  desc = "Disable spell check for all files",
})

-- Force disable diagnostics after LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    -- Disable all diagnostics for this buffer
    vim.diagnostic.disable(args.buf)
  end,
  desc = "Disable diagnostics when LSP attaches",
})

-- Also disable diagnostics globally on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.diagnostic.disable()
  end,
  desc = "Disable diagnostics globally on startup",
})
