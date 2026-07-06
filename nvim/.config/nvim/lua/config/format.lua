local conform = require("conform")

local intellij_format = vim.fn.expand("~/Applications/IntelliJ IDEA.app/Contents/bin/format.sh")
local intellij_code_style = vim.fn.stdpath("config") .. "/codestyles/jetbrains/ktown4u-java-code-style.xml"

local function format_timeout(bufnr)
  local filetype = vim.bo[bufnr].filetype
  return (filetype == "java" or filetype == "kotlin") and 30000 or 1000
end

local function format_opts(bufnr)
  return {
    timeout_ms = format_timeout(bufnr),
    lsp_format = "fallback",
  }
end

local function format_on_save_opts(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype == "java" or filetype == "kotlin" then
    return
  end

  return format_opts(bufnr)
end

conform.setup({
  formatters_by_ft = {
    graphql = { "prettier" },
    java = { "intellij_idea" },
    json = { "prettier" },
    jsonc = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    kotlin = { "intellij_idea" },
    lua = { "stylua" },
    markdown = { "prettier" },
    mysql = { "sleek" },
    sh = { "shfmt" },
    sql = { "sleek" },
    toml = { "taplo" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    yaml = { "prettier" },
    zsh = { "shfmt" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_on_save = format_on_save_opts,
  formatters = {
    intellij_idea = {
      command = intellij_format,
      args = { "-s", intellij_code_style, "$FILENAME" },
      stdin = false,
      condition = function()
        return vim.fn.executable(intellij_format) == 1 and vim.fn.filereadable(intellij_code_style) == 1
      end,
    },
  },
})

vim.api.nvim_create_user_command("Format", function()
  conform.format(format_opts(0))
end, { desc = "Format current buffer" })
