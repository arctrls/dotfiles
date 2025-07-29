return {
  -- Configure diagnostics after LSP setup
  {
    "neovim/nvim-lspconfig", 
    init = function()
      -- Disable diagnostics
      vim.diagnostic.config({
        virtual_text = false,
        signs = false,
        underline = false,
        update_in_insert = false,
        severity_sort = false,
      })
    end,
  },
}