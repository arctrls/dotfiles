local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    graphql = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
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
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

vim.api.nvim_create_user_command("Format", function()
  conform.format({ async = false, lsp_format = "fallback" })
end, { desc = "Format current buffer" })
