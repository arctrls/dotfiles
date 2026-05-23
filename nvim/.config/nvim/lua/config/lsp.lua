local capabilities = require("blink.cmp").get_lsp_capabilities()

local function version_numbers(version)
  local numbers = {}
  for number in version:gmatch("%d+") do
    table.insert(numbers, tonumber(number))
  end
  return numbers
end

local function version_greater_than(left, right)
  local left_numbers = version_numbers(left)
  local right_numbers = version_numbers(right)
  local length = math.max(#left_numbers, #right_numbers)

  for index = 1, length do
    local left_number = left_numbers[index] or 0
    local right_number = right_numbers[index] or 0
    if left_number ~= right_number then
      return left_number > right_number
    end
  end

  return left > right
end

local function lombok_version(path)
  return path:match("/lombok/([^/]+)/lombok%-.*%.jar$") or ""
end

local function find_lombok_jar()
  local pattern = vim.fn.expand("~") .. "/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar"
  local jars = vim.fn.glob(pattern, true, true)
  table.sort(jars, function(left, right)
    return version_greater_than(lombok_version(left), lombok_version(right))
  end)

  return jars[1]
end

local lombok_jar = find_lombok_jar()
if lombok_jar then
  vim.env.JDTLS_JVM_ARGS = "-javaagent:" .. lombok_jar .. " " .. (vim.env.JDTLS_JVM_ARGS or "")
end

local servers = {
  bashls = {},
  graphql = {},
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
  sqlls = {},
  taplo = {},
  ts_ls = {},
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  vim.lsp.config(server, config)
end

vim.lsp.config("jdtls", {
  capabilities = capabilities,
  detached = false,
})
vim.lsp.enable("jdtls")

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
  "sleek",
  "stylua",
  "taplo",
})
