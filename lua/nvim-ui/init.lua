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
        statusline = true,    -- Status line
    },

    -- Settings configuration
    settings = {
        display = {
            number = true,             -- Show line numbers
            relativenumber = false,    -- Use relative line numbers
            termguicolors = true,     -- Enable 24-bit colors
            showmode = false,         -- Don't show mode in command line
            showcmd = true,           -- Show command in status line
            cmdheight = 1,            -- Height of command line
            scrolloff = 8,            -- Lines of context
            wrap = false,             -- Don't wrap lines
            fillchars = {
                eob = " ",            -- Empty lines at end of buffer
            },
            listchars = {
                tab = "→ ",
                trail = "·",
                extends = "›",
                precedes = "‹",
                nbsp = "␣",
            },
        },
        behavior = {
            mouse = "a",              -- Enable mouse in all modes
            clipboard = "unnamedplus", -- Use system clipboard
            hidden = true,            -- Keep hidden buffers
            backup = false,           -- Don't create backup files
            swapfile = false,         -- Don't create swap files
            undofile = true,          -- Persistent undo
            timeoutlen = 300,         -- Time to wait for mapped sequence
            updatetime = 300,         -- Faster completion
            ignorecase = true,        -- Ignore case in search
            smartcase = true,         -- Unless uppercase is used
        },
        system = {
            shell = vim.o.shell,      -- Use system shell
            encoding = "utf-8",       -- Default encoding
            fileencoding = "utf-8",   -- File encoding
        },
        startup = {
            disable_netrw = true,     -- Disable netrw
            disable_start_msg = true, -- Disable intro message
        },
    },

    -- Tree configuration
    tree = {
        view = {
            width = {
                min = 30,
                max = 50,
                padding = 1,
            },
            side = "left",
        },
        git = {
            enable = true,
        },
    },

    -- Terminal configuration
    terminal = {
        shell = vim.o.shell,
        float_size = { width = 0.8, height = 0.8 },
        horizontal_size = 15,
        vertical_size = 80,
    },

    -- Status line configuration
    statusline = {
        theme = "auto",
        global_status = true,
        sections = {
            lualine_a = {
                {
                    "mode",
                    icons_enabled = true,
                    padding = { left = 1, right = 1 },
                },
            },
            lualine_b = {
                {
                    "branch",
                    icon = "",
                    padding = { left = 1, right = 1 },
                },
                {
                    "diff",
                    symbols = {
                        added = " ",
                        modified = " ",
                        removed = " ",
                    },
                },
                {
                    "diagnostics",
                    sources = { "nvim_diagnostic" },
                    symbols = {
                        error = " ",
                        warn = " ",
                        info = " ",
                        hint = " ",
                    },
                },
            },
            lualine_c = {
                {
                    "filename",
                    path = 1,
                    symbols = {
                        modified = "●",
                        readonly = "",
                        unnamed = "[No Name]",
                    },
                },
            },
        },
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
}

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
        "which-key",
        "lualine",
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

    -- Check dependencies
    if not check_dependencies() then
        return
    end

    -- Set up components in the correct order
    local components = {
        -- Settings should be first to ensure proper display
        { name = "settings", enabled = true },
        -- Statusline should be early to ensure proper display
        { name = "statusline", enabled = M.options.features.statusline },
        -- Format should be next to ensure proper display
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
end

return M
