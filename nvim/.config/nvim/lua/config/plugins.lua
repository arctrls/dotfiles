local add = MiniDeps.add

add("scottmckendry/cyberdream.nvim")
add("iamcco/markdown-preview.nvim")
add("lewis6991/gitsigns.nvim")
add("mason-org/mason.nvim")
add("mason-org/mason-lspconfig.nvim")
add("neovim/nvim-lspconfig")
add("nvim-tree/nvim-web-devicons")
add("ibhagwan/fzf-lua")
add("folke/trouble.nvim")
add("stevearc/aerial.nvim")
add("christoomey/vim-tmux-navigator")
add({
  source = "nvim-treesitter/nvim-treesitter",
  hooks = {
    post_checkout = function()
      pcall(vim.cmd, "TSUpdate")
    end,
  },
})
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

local treesitter_parsers = {
  "bash",
  "java",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "query",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
  "zsh",
}

local treesitter_languages = {
  bash = { "bash", "sh" },
  java = { "java" },
  json = { "json", "jsonc" },
  lua = { "lua" },
  markdown = { "markdown" },
  query = { "query" },
  toml = { "toml" },
  vim = { "vim" },
  vimdoc = { "help" },
  yaml = { "yaml" },
  zsh = { "zsh" },
}

local treesitter = require("nvim-treesitter")

treesitter.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

treesitter.install(treesitter_parsers)

for lang, filetypes in pairs(treesitter_languages) do
  for _, filetype in ipairs(filetypes) do
    vim.treesitter.language.register(lang, filetype)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "bash",
    "help",
    "java",
    "json",
    "jsonc",
    "lua",
    "markdown",
    "query",
    "sh",
    "toml",
    "vim",
    "yaml",
    "zsh",
  },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

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

require("fzf-lua").setup({
  winopts = {
    height = 0.85,
    width = 0.9,
    preview = {
      layout = "flex",
    },
  },
})

require("trouble").setup({})

require("aerial").setup({
  backends = { "lsp", "treesitter", "markdown" },
  layout = {
    min_width = 28,
    default_direction = "right",
  },
  show_guides = true,
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
