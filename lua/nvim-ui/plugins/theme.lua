-- lua/plugins/themes.lua
-- Function to setup common highlight groups for special characters
local function setup_list_chars_highlights()
  -- Ensure special characters are visible
  vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#FFFFFF' })  -- for spaces
  vim.api.nvim_set_hl(0, 'NonText', { fg = '#004945' })     -- for eol and extends
  vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#004945' })  -- for other special chars
end

-- Theme definitions table
local themes = {
  catppuccin = {
    name = "catppuccin/nvim",
    plugin_name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        integrations = {
          -- Enable various integrations
          indent_blankline = true,
        },
      })
    end
  },
  tokyonight = {
    name = "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        on_highlights = function(hl, c)
          -- Customize highlight groups if needed
          hl.Whitespace = { fg = c.dark3 }
          hl.NonText = { fg = c.dark3 }
          hl.SpecialKey = { fg = c.dark3 }
        end
      })
    end
  },
  github_light = {
    name = "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({
        options = {
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
      })
      -- Set to light theme specifically
      vim.cmd('colorscheme github_light')
    end
  },
  github_dark = {
    name = "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({
        options = {
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
      })
      -- Set to dark theme specifically
      vim.cmd('colorscheme github_dark')
    end
  },
  -- Add new themes easily:
  -- new_theme = {
  --   name = "author/plugin-name",
  --   plugin_name = "colorscheme_name", -- optional, if different from key
  --   config = function() -- optional
  --     -- theme specific setup
  --   end
  -- },
}

-- Convert themes table to lazy.nvim plugin specs
local theme_plugins = {}
for theme_name, theme_data in pairs(themes) do
  table.insert(theme_plugins, {
    theme_data.name,
    name = theme_data.plugin_name,
    priority = 1000,
    lazy = false,
    config = theme_data.config,
  })
end

-- Add theme loader plugin
table.insert(theme_plugins, {
  "LazyVim/LazyVim",
  priority = 1000,
  lazy = false,
  config = function()
    local theme_choice = vim.g.theme_choice or "catppuccin"

    -- Validate theme choice
    if not themes[theme_choice] then
      vim.notify(
        "Theme '" .. theme_choice .. "' not found, falling back to catppuccin",
        vim.log.levels.WARN
      )
      theme_choice = "catppuccin"
    end

    -- Apply theme-specific config if it exists
    if themes[theme_choice].config then
      themes[theme_choice].config()
    end

    -- Set the colorscheme
    local colorscheme_name = themes[theme_choice].plugin_name or theme_choice
    vim.cmd.colorscheme(colorscheme_name)
  end,
})

return theme_plugins

