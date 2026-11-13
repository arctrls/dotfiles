local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root .. "/nvim/.config/nvim")
local navigation = require("config.herdr_navigation")
local calls = {}
vim.system = function(argv)
  calls[#calls + 1] = argv
  return {
    wait = function(_, timeout)
      assert(timeout == 1000)
      return { code = 0, stdout = "", stderr = "" }
    end,
  }
end

vim.env.HERDR_PANE_ID = nil
vim.env.TMUX = "existing-tmux"
navigation.setup()
assert(vim.fn.maparg("<C-h>", "n") == "", "Keep tmux mappings untouched")

vim.env.TMUX = nil
vim.env.HERDR_PANE_ID = "w1:p1"
navigation.setup()
local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  local mapping = vim.fn.maparg("<C-" .. key .. ">", "n", false, true)
  assert(type(mapping.callback) == "function", "Missing navigation mapping: " .. key)
  mapping.callback()
  assert(vim.deep_equal(calls[#calls], { "herdr", "pane", "focus", "--current", "--direction", direction }))
end

calls = {}
vim.cmd.vsplit()
vim.cmd.wincmd("h")
local left = vim.api.nvim_get_current_win()
vim.fn.maparg("<C-l>", "n", false, true).callback()
assert(vim.api.nvim_get_current_win() ~= left, "Move within Neovim before changing Herdr panes")
assert(#calls == 0, "Internal window movement must not invoke Herdr")
vim.fn.maparg("<C-l>", "n", false, true).callback()
assert(#calls == 1, "At the editor edge, move to the neighboring Herdr pane")
print("PASS: tmux mappings, four directions, Neovim windows, Herdr boundary")
