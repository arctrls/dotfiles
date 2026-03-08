vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ lsp_format = "fallback", async = false })
end, { desc = "Format buffer" })
