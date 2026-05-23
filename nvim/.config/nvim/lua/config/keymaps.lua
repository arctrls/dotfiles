vim.keymap.set({ "n", "v" }, "<leader>f", function()
  require("conform").format({ lsp_format = "fallback", async = false })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader><Esc>", function()
  vim.fn.setreg("/", "")
end, { desc = "Clear search pattern" })

vim.keymap.set("n", "<leader><space>", function()
  require("fzf-lua").files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })

vim.keymap.set("n", "<leader>,", function()
  require("fzf-lua").buffers()
end, { desc = "Find buffers" })

vim.keymap.set("n", "<leader>/", function()
  require("fzf-lua").live_grep()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>*", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  require("fzf-lua").grep({
    search = word,
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --fixed-strings --",
  })
end, { desc = "Grep word under cursor" })

vim.keymap.set("n", "<leader>sd", function()
  require("fzf-lua").diagnostics_workspace()
end, { desc = "Search diagnostics" })

vim.keymap.set("n", "<leader>ss", function()
  require("fzf-lua").lsp_document_symbols()
end, { desc = "Search document symbols" })

vim.keymap.set("n", "<leader>sS", function()
  require("fzf-lua").lsp_live_workspace_symbols()
end, { desc = "Search workspace symbols" })

vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<cr>", { desc = "Toggle outline" })
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Toggle quickfix" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", function()
      require("fzf-lua").lsp_definitions({ jump1 = true })
    end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))

    vim.keymap.set("n", "gi", function()
      require("fzf-lua").lsp_implementations({ jump1 = true })
    end, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))

    vim.keymap.set("n", "gr", function()
      require("fzf-lua").lsp_references({ ignore_current_line = true })
    end, vim.tbl_extend("force", opts, { desc = "Go to references" }))

    vim.keymap.set("n", "gy", function()
      require("fzf-lua").lsp_typedefs({ jump1 = true })
    end, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run code lens" }))
    vim.keymap.set(
      "n",
      "<leader>ci",
      vim.lsp.buf.incoming_calls,
      vim.tbl_extend("force", opts, { desc = "Incoming calls" })
    )
    vim.keymap.set(
      "n",
      "<leader>co",
      vim.lsp.buf.outgoing_calls,
      vim.tbl_extend("force", opts, { desc = "Outgoing calls" })
    )
    vim.keymap.set(
      "n",
      "<leader>cr",
      vim.lsp.buf.references,
      vim.tbl_extend("force", opts, { desc = "References quickfix" })
    )
  end,
})
