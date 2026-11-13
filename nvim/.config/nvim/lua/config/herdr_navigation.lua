local M = {}

function M.setup()
  if not vim.env.HERDR_PANE_ID or vim.env.TMUX then
    return
  end

  for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      local previous_window = vim.api.nvim_get_current_win()
      vim.cmd.wincmd(key)
      if vim.api.nvim_get_current_win() ~= previous_window then
        return
      end

      local result = vim.system({ "herdr", "pane", "focus", "--current", "--direction", direction }):wait(1000)
      if result.code ~= 0 then
        vim.notify("Herdr pane navigation failed: " .. (result.stderr or ""), vim.log.levels.WARN)
      end
    end, { desc = "Move to " .. direction .. " window or Herdr pane" })
  end
end

return M
