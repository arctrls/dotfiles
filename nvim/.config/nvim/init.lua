vim.g.mapleader = " "
vim.g.maplocalleader = " "

local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"

if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing mini.nvim" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  if vim.v.shell_error ~= 0 then
    error("Failed to install mini.nvim")
  end
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed mini.nvim" | redraw')
end

require("mini.deps").setup({ path = { package = path_package } })

require("config.options")
require("config.keymaps")
require("config.plugins")
require("config.statusline")
require("config.completion")
require("config.lsp")
require("config.format")
