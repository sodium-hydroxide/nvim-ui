-- init.lua for nvim-ui
--[[
 * @brief Main entry point for the UI package
 * @module nvim-ui
 *
 * This module coordinates all UI components and ensures they work together
 * harmoniously. It handles initialization order, shared configurations,
 * and component integration.
--]]
local M = {}

--[[
 * @brief Default configuration for the entire UI package
 * @field features Table of feature flags for components
--]]
M.options = {
    -- Core features
    features = {
        tree = true,          -- File explorer
        terminal = true,      -- Integrated terminal
        format = true,        -- Text formatting
        which_key = true,     -- Keymap hints
    },

    -- Startup configuration
    startup = {
        disable_message = true,  -- Disable default startup message
        show_keybinds = true,   -- Show custom keybind information
    },

    -- Color scheme configuration
    colorscheme = {
        name = "xcodelight",
        background = "light",
        transparent = false,
    },

    -- Tree configuration
    tree = {
        view = {
            width = {
                min = 30,
                max = 30,
            },
            side = "left",
        },
        renderer = {
            group_empty = true,
            highlight_git = true,
            indent_width = 2,
            indent_markers = {
                enable = true,
                inline_arrows = true,
                icons = {
                    corner = "└",
                    edge = "│",
                    item = "│",
                    bottom = "─",
                    none = " ",
                },
            },
            icons = {
                webdev_colors = true,
                show = {
                    file = true,
                    folder = true,
                    folder_arrow = true,
                    git = true,
                },
            },
        },
        git = {
            enable = true,
            ignore = true,
            timeout = 400,
        },
    },

    -- Terminal configuration
    terminal = {
        shell = vim.o.shell,
        float_size = { width = 0.8, height = 0.8 },
        horizontal_size = 15,
        vertical_size = 80,
    },

    -- Text formatting
    format = {
        trim_whitespace = true,
        final_newline = true,
        max_blank_lines = 2,
        format_on_save = true,
        show_whitespace = true,
        listchars = {
            tab = "»·",
            trail = "~",
            nbsp = "‡",
            extends = "›",
            precedes = "‹",
            space = "⋅",
            eol = "¬"
        },
    },

    -- Shared keymaps used by multiple components
    keymaps = {
        -- Tree toggles
        tree_toggle = "<leader>e",
        tree_focus = "<leader>o",

        -- Terminal toggles
        term_toggle = "<C-\\>",
        term_float = "<leader>tf",
        term_horizontal = "<leader>th",
        term_vertical = "<leader>tv",
    }
}

--[[
 * @brief Displays custom startup information
 * @local
--]]
local function display_startup_info()
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer content
    local lines = {
        "Welcome to Neovim!",
        "",
        "Quick Reference:",
        "─────────────────",
        "",
        "File Tree:",
        "  <leader>e - Toggle file tree",
        "  <leader>o - Focus file tree",
        "",
        "Terminal:",
        "  <leader>tf - Toggle floating terminal",
        "  <leader>th - Toggle horizontal terminal",
        "  <leader>tv - Toggle vertical terminal",
        "",
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)

    -- Open buffer in current window
    vim.api.nvim_set_current_buf(buf)
end

--[[
 * @brief Ensures required plugins are available
 * @return boolean True if all required plugins are present
 * @local
--]]
local function check_dependencies()
    local required_plugins = {
        "nvim-tree",
        "toggleterm",
        "telescope",
        "which-key"
    }

    for _, plugin in ipairs(required_plugins) do
        if not pcall(require, plugin) then
            vim.notify(
                string.format("nvim-ui requires %s to be installed", plugin),
                vim.log.levels.ERROR
            )
            return false
        end
    end

    return true
end

--[[
 * @brief Main setup function that initializes all components
 * @param opts table Optional configuration overrides
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    -- Disable default startup message if configured
    if M.options.startup.disable_message then
        vim.opt.shortmess:append("I")
    end

    -- Check dependencies
    if not check_dependencies() then
        return
    end

    -- Set up components in the correct order
    local components = {
        -- Format should be first to ensure proper display
        { name = "format", enabled = M.options.features.format },
        -- Tree and terminal provide core functionality
        { name = "tree", enabled = M.options.features.tree },
        { name = "terminal", enabled = M.options.features.terminal },
        -- Keymaps should be last to ensure all commands are available
        { name = "keymaps", enabled = true },
    }

    -- Initialize each component
    for _, component in ipairs(components) do
        if component.enabled then
            local ok, err = pcall(
                require("nvim-ui." .. component.name).setup,
                M.options[component.name]
            )
            if not ok then
                vim.notify(
                    string.format("Error setting up %s: %s", component.name, err),
                    vim.log.levels.ERROR
                )
            end
        end
    end

    -- Display startup information if configured
    if M.options.startup.show_keybinds then
        -- Only show on empty buffers at startup
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                -- Check if we're opening a file or not
                local argc = vim.fn.argc()
                local bufname = vim.api.nvim_buf_get_name(0)
                if argc == 0 and bufname == "" then
                    display_startup_info()
                end
            end,
            once = true,
        })
    end
end

return M
