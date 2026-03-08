local add = MiniDeps.add

add("scottmckendry/cyberdream.nvim")
add("iamcco/markdown-preview.nvim")
add("lewis6991/gitsigns.nvim")
add("mason-org/mason.nvim")
add("mason-org/mason-lspconfig.nvim")
add("neovim/nvim-lspconfig")
add("saghen/blink.cmp")
add("stevearc/conform.nvim")

vim.g.mkdp_auto_start = 0
vim.g.mkdp_filetypes = { "markdown" }

local markdown_preview_root = vim.fn.stdpath("data") .. "/site/pack/deps/opt/markdown-preview.nvim"
local markdown_preview_app = markdown_preview_root .. "/app"
if vim.uv.fs_stat(markdown_preview_root) then
  vim.cmd("packadd markdown-preview.nvim")
end
if vim.uv.fs_stat(markdown_preview_app) and not vim.uv.fs_stat(markdown_preview_app .. "/node_modules") then
  local out = vim.fn.system({
    "sh",
    "-c",
    "cd " .. vim.fn.shellescape(markdown_preview_app) .. " && npm install",
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("markdown-preview.nvim install failed:\n" .. out, vim.log.levels.ERROR)
  end
end

require("gitsigns").setup({
  signs = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  current_line_blame = false,
})

require("cyberdream").setup({
  variant = "light",
  overrides = function(colors)
    return {
      CursorLine = { bg = "#f5f5f5" },
      CursorLineNr = { fg = colors.fg, bg = "#f5f5f5", bold = true },
      Visual = { bg = "#b4d5fe" },
      VisualNOS = { bg = "#b4d5fe" },
      Search = { bg = "#ffd33d" },
      IncSearch = { bg = "#ffd33d" },
    }
  end,
})

vim.cmd.colorscheme("cyberdream")
