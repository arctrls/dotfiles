local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  bashls = {},
  jsonls = {},
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
        runtime = {
          version = "LuaJIT",
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
  },
  marksman = {},
  taplo = {},
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  vim.lsp.config(server, config)
end

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = true,
})

local function ensure_tools_installed(tools)
  local registry = require("mason-registry")

  registry.refresh(function()
    for _, tool in ipairs(tools) do
      local ok, pkg = pcall(registry.get_package, tool)
      if ok and not pkg:is_installed() then
        pkg:install()
      end
    end
  end)
end

ensure_tools_installed({
  "prettier",
  "shfmt",
  "stylua",
  "taplo",
})
