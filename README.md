# nvim-ui

A comprehensive UI enhancement package for Neovim that provides a cohesive and
polished development environment. This package combines several carefully
configured components to create a consistent and productive interface.

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
    config = function()
        local plugins = require("nvim-ui").setup({
            leader = " ",
            localleader = "\\",
            theme = "github_light",
        })
        require("lazy").setup(plugins)
    end,
}
```

