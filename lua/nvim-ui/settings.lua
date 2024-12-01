--[[
 * @brief Manages core editor settings and behaviors
 * @module nvim-ui.settings
 *
 * This module handles basic editor configurations like:
 * - Line numbering and display options
 * - Mouse and terminal support
 * - Color and UI preferences
 * - Buffer and window behaviors
 * - System integration settings
--]]
local M = {}

--[[
 * @brief Default settings configuration
 * @field display Visual display settings
 * @field behavior Editor behavior settings
 * @field system System integration settings
 * @local
--]]
local default_config = {
    -- Display settings
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

    -- Behavior settings
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

    -- System settings
    system = {
        shell = vim.o.shell,      -- Use system shell
        encoding = "utf-8",       -- Default encoding
        fileencoding = "utf-8",   -- File encoding
    },

    -- Startup settings
    startup = {
        disable_netrw = true,     -- Disable netrw
        disable_start_msg = true, -- Disable intro message
    }
}

--[[
 * @brief Applies global vim options
 * @param opts table Options to apply
 * @local
--]]
local function apply_options(opts)
    -- Display settings
    vim.opt.number = opts.display.number
    vim.opt.relativenumber = opts.display.relativenumber
    vim.opt.termguicolors = opts.display.termguicolors
    vim.opt.showmode = opts.display.showmode
    vim.opt.showcmd = opts.display.showcmd
    vim.opt.cmdheight = opts.display.cmdheight
    vim.opt.scrolloff = opts.display.scrolloff
    vim.opt.wrap = opts.display.wrap
    vim.opt.fillchars = opts.display.fillchars
    vim.opt.listchars = opts.display.listchars

    -- Behavior settings
    vim.opt.mouse = opts.behavior.mouse
    vim.opt.clipboard = opts.behavior.clipboard
    vim.opt.hidden = opts.behavior.hidden
    vim.opt.backup = opts.behavior.backup
    vim.opt.swapfile = opts.behavior.swapfile
    vim.opt.undofile = opts.behavior.undofile
    vim.opt.timeoutlen = opts.behavior.timeoutlen
    vim.opt.updatetime = opts.behavior.updatetime
    vim.opt.ignorecase = opts.behavior.ignorecase
    vim.opt.smartcase = opts.behavior.smartcase

    -- System settings
    vim.opt.shell = opts.system.shell
    vim.opt.encoding = opts.system.encoding
    vim.opt.fileencoding = opts.system.fileencoding

    -- Startup settings
    if opts.startup.disable_netrw then
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end
end

--[[
 * @brief Disables default startup message
 * @local
--]]
local function disable_start_message()
    vim.opt.shortmess:append("I")
end

--[[
 * @brief Main setup function for editor settings
 * @param opts table Configuration options from main setup
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    local config = vim.tbl_deep_extend("force", default_config, opts or {})

    -- Apply all options
    apply_options(config)

    -- Disable startup message if configured
    if config.startup.disable_start_msg then
        disable_start_message()
    end
end

return M
