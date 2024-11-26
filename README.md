# nvim-ui

A comprehensive UI enhancement package for Neovim that provides a cohesive and polished development environment. This package combines several carefully configured components to create a consistent and productive interface.

## Features

### File Explorer
- Clean, informative tree view with git integration
- Smart handling of window positioning and focus
- Intuitive keymaps for navigation and file operations
- Consistent behavior with buffer management

### Integrated Terminal
- Multiple terminal layouts (floating, horizontal, vertical)
- Smart window sizing and positioning
- Consistent keybindings across terminal types
- Seamless integration with Neovim's features

### Text Formatting
- Automatic trailing whitespace removal
- Consistent final newline handling
- Smart blank line management
- Configurable whitespace visualization
- Format-on-save capability

### Keybinding System
- Logical organization by function
- Integration with which-key for discoverability
- Consistent patterns across different tools
- Easy customization options

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "sodium-hydroxide/nvim-ui",
    dependencies = {
        "nvim-tree/nvim-tree.lua",
        "nvim-tree/nvim-web-devicons",
        "akinsho/toggleterm.nvim",
        "nvim-telescope/telescope.nvim",
        "folke/which-key.nvim",
    },
    config = function()
        require("nvim-ui").setup({
            -- Optional: override default options
            features = {
                tree = true,          -- File explorer
                terminal = true,      -- Integrated terminal
                format = true,        -- Text formatting
                which_key = true,     -- Keymap hints
            },
            -- Component-specific options
            tree = {
                width = 30,
                side = "left",
                git_integration = true,
            },
            terminal = {
                shell = vim.o.shell,
                float_size = { width = 0.8, height = 0.8 },
            },
            format = {
                trim_whitespace = true,
                final_newline = true,
                show_whitespace = true,
            }
        })
    end
}
```

## Default Keybindings

### File Explorer
- `<leader>e` - Toggle file tree
- `<leader>o` - Focus file tree

### Terminal
- `<C-\>` - Toggle terminal
- `<leader>tf` - Toggle floating terminal
- `<leader>th` - Toggle horizontal terminal
- `<leader>tv` - Toggle vertical terminal

### Window Navigation
- `<C-h>` - Move to left window
- `<C-j>` - Move to bottom window
- `<C-k>` - Move to top window
- `<C-l>` - Move to right window

### File Operations
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fr` - Recent files

## Customization

You can customize any aspect of the UI package by passing options to the setup function:

```lua
require("nvim-ui").setup({
    -- Disable components you don't want
    features = {
        tree = true,
        terminal = false,  -- Disable terminal integration
        format = true,
    },

    -- Customize the file tree
    tree = {
        width = 40,  -- Wider tree
        side = "right",  -- Move to right side
    },

    -- Customize terminal behavior
    terminal = {
        float_size = {
            width = 0.9,  -- Larger floating terminal
            height = 0.9,
        },
    },

    -- Customize formatting
    format = {
        trim_whitespace = true,
        max_blank_lines = 1,  -- More aggressive blank line removal
        listchars = {
            -- Custom whitespace characters
            tab = "→ ",
            trail = "·",
        },
    },
})
```

## Component Integration

The package ensures all components work together seamlessly:

1. The file tree respects terminal windows and vice versa
2. Formatting applies consistently across all file types
3. Keybindings are organized logically and don't conflict
4. All components follow your color scheme

## Requirements

- Neovim >= 0.8.0
- Required plugins:
  - nvim-tree.lua
  - toggleterm.nvim
  - telescope.nvim
  - which-key.nvim

## Contributing

Contributions are welcome! Areas of particular interest:

1. Additional UI components
2. Enhanced integration between components
3. New formatting options
4. Performance improvements

## License

MIT License - See LICENSE for details
