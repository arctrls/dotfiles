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
  overrides = function()
    local idea = {
      bg = "#ffffff",
      fg = "#080808",
      line = "#f5f5f5",
      selection = "#a6d2ff",
      search = "#fff2a8",
      comment = "#808080",
      string = "#008000",
      number = "#0000ff",
      type = "#000080",
      method = "#00627a",
      field = "#871094",
      annotation = "#808000",
    }

    return {
      Normal = { fg = idea.fg, bg = idea.bg },
      NormalFloat = { fg = idea.fg, bg = idea.bg },
      SignColumn = { bg = idea.bg },
      CursorLine = { bg = idea.line },
      CursorLineNr = { fg = idea.fg, bg = idea.line, bold = true },
      Visual = { bg = idea.selection },
      VisualNOS = { bg = idea.selection },
      Search = { bg = idea.search },
      IncSearch = { bg = idea.search },
      Comment = { fg = idea.comment },
      String = { fg = idea.string },
      Number = { fg = idea.number },
      Boolean = { fg = idea.number },
      Type = { fg = idea.type },
      Function = { fg = idea.method },

      -- Tree-sitter highlight overrides live here.
      ["@keyword"] = { fg = idea.fg },
      ["@keyword.conditional"] = { fg = idea.fg },
      ["@keyword.exception"] = { fg = idea.fg },
      ["@keyword.import"] = { fg = idea.fg },
      ["@keyword.modifier"] = { fg = idea.fg },
      ["@keyword.operator"] = { fg = idea.fg },
      ["@keyword.repeat"] = { fg = idea.fg },
      ["@keyword.return"] = { fg = idea.fg },
      ["@keyword.type"] = { fg = idea.fg },
      ["@comment"] = { fg = idea.comment },
      ["@string"] = { fg = idea.string },
      ["@number"] = { fg = idea.number },
      ["@boolean"] = { fg = idea.number },
      ["@type"] = { fg = idea.type },
      ["@function"] = { fg = idea.method },
      ["@function.method"] = { fg = idea.method },
      ["@function.method.call"] = { fg = idea.method },
      ["@variable.builtin"] = { fg = idea.fg },
      ["@variable.member"] = { fg = idea.field },
      ["@attribute"] = { fg = idea.annotation },
      ["@lsp.type.class.java"] = { fg = idea.type },
      ["@lsp.type.enum.java"] = { fg = idea.type },
      ["@lsp.type.interface.java"] = { fg = idea.type },
      ["@lsp.type.type.java"] = { fg = idea.type },
      ["@lsp.type.enumMember.java"] = { fg = idea.field },
      ["@lsp.type.keyword.java"] = { fg = idea.fg },
      ["@lsp.type.modifier.java"] = { fg = idea.fg },
      ["@lsp.type.namespace.java"] = { fg = idea.fg },
    }
  end,
})

vim.cmd.colorscheme("cyberdream")
