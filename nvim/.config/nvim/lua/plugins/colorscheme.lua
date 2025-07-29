return {
  -- Cyberdream colorscheme
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        variant = "light",
        -- Override cursorline to be more subtle
        overrides = function(colors)
          return {
            -- Make cursorline background more transparent/lighter
            CursorLine = { bg = "#f5f5f5" }, -- Very light gray
            CursorLineNr = { fg = colors.fg, bg = "#f5f5f5", bold = true },
            
            -- macOS-style selection colors (light blue)
            Visual = { bg = "#b4d5fe" }, -- macOS selection blue
            VisualNOS = { bg = "#b4d5fe" },
            -- Optional: also update search highlights to match
            Search = { bg = "#ffd33d" }, -- macOS yellow search highlight
            IncSearch = { bg = "#ffd33d" },
          }
        end,
      })
    end,
  },

  -- Configure LazyVim to load cyberdream
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },
}