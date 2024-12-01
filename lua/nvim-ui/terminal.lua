--[[
 * @brief Manages integrated terminal functionality
 * @module nvim-ui.terminal
 *
 * This module provides a sophisticated terminal integration that makes it easy
 * to perform command-line operations without leaving Neovim. It supports multiple
 * terminal styles (floating, horizontal, vertical) and intelligent terminal
 * management to match your workflow.
 *
 * The terminal configuration emphasizes:
 * - Quick access through intuitive keymaps
 * - Smart window positioning and sizing
 * - Consistent behavior across terminal types
 * - Seamless integration with Neovim's features
--]]
local M = {}

--[[
 * @brief Default terminal configuration
 * @field shell Preferred shell for terminals
 * @field layouts Settings for different terminal layouts
 * @field behavior Terminal behavior settings
 * @local
 *
 * This configuration creates a terminal experience that feels natural within
 * Neovim while providing the full power of your shell. Each setting is chosen
 * to support efficient terminal use while maintaining a clean interface.
--]]
local default_config = {
    -- Shell configuration
    shell = vim.o.shell,

    -- Terminal window layouts
    layouts = {
        floating = {
            -- Floating window takes up significant but not full screen space
            width = 0.8,
            height = 0.8,
            border = "curved",
            -- Position in the center of the screen
            anchor = "center",
            winblend = 0,
        },
        horizontal = {
            -- Height is adaptive but with a minimum
            size = function(term)
                return math.max(15, vim.o.lines * 0.3)
            end,
            direction = "horizontal",
        },
        vertical = {
            -- Width takes up a reasonable portion of the screen
            size = function(term)
                return math.max(80, vim.o.columns * 0.4)
            end,
            direction = "vertical",
        },
    },

    -- Terminal behavior
    behavior = {
        -- Close terminal when shell exits
        close_on_exit = true,
        -- Insert mode when opening terminal
        start_in_insert = true,
        -- Terminal-specific keymaps
        insert_mappings = true,
        terminal_mappings = true,
        -- Preserve terminal content when hiding
        persist_size = true,
        -- Shell command persistence
        persist_mode = true,
    },

    -- Visual settings
    visual = {
        -- No line numbers in terminal
        numbers = false,
        -- Use a minimal status line
        statusline = false,
        -- Highlight settings
        highlights = {
            Normal = { link = "Normal" },
            NormalFloat = { link = "Normal" },
            FloatBorder = { link = "Normal" },
        },
    },
}

--[[
 * @brief Creates a new terminal instance with specific settings
 * @param layout string The layout type ('floating', 'horizontal', 'vertical')
 * @param opts table Configuration options
 * @return Terminal The created terminal instance
 * @local
 *
 * This function handles the creation and configuration of terminal instances,
 * ensuring consistent behavior regardless of the chosen layout.
--]]
local function create_terminal(layout, opts)
    local Terminal = require("toggleterm.terminal").Terminal
    local layouts = opts.layouts

    local config = {
        shell = opts.shell,
        close_on_exit = opts.behavior.close_on_exit,
        start_in_insert = opts.behavior.start_in_insert,
        insert_mappings = opts.behavior.insert_mappings,
        terminal_mappings = opts.behavior.terminal_mappings,
        persist_size = opts.behavior.persist_size,
        persist_mode = opts.behavior.persist_mode,
        highlights = opts.visual.highlights,
    }

    -- Add layout-specific settings
    if layout == "floating" then
        config.direction = "float"
        config.float_opts = {
            border = layouts.floating.border,
            width = math.floor(vim.o.columns * layouts.floating.width),
            height = math.floor(vim.o.lines * layouts.floating.height),
            winblend = layouts.floating.winblend,
        }
    elseif layout == "horizontal" then
        config.direction = layouts.horizontal.direction
        config.size = layouts.horizontal.size
    else -- vertical
        config.direction = layouts.vertical.direction
        config.size = layouts.vertical.size
    end

    return Terminal:new(config)
end

--[[
 * @brief Sets up terminal-specific keymaps
 * @param term Terminal The terminal instance
 * @param opts table Configuration options
 * @local
 *
 * These keymaps make it easy to work with terminals while maintaining
 * Neovim's keyboard-driven workflow. They provide quick access to common
 * terminal operations.
--]]
local function setup_keymaps(term, opts)
    -- Terminal navigation in normal mode
    local function set_keymap(mode, key, action, desc)
        vim.keymap.set(mode, key, action, {
            silent = true,
            noremap = true,
            desc = desc
        })
    end

    -- Easy escape from terminal mode
    set_keymap('t', '<C-\\><C-\\>', '<C-\\><C-n>',
        'Exit terminal mode')

    -- Window navigation from terminal
    set_keymap('t', '<C-h>', '<C-\\><C-n><C-w>h',
        'Navigate left from terminal')
    set_keymap('t', '<C-j>', '<C-\\><C-n><C-w>j',
        'Navigate down from terminal')
    set_keymap('t', '<C-k>', '<C-\\><C-n><C-w>k',
        'Navigate up from terminal')
    set_keymap('t', '<C-l>', '<C-\\><C-n><C-w>l',
        'Navigate right from terminal')

    -- Terminal window management
    set_keymap('t', '<C-w>N', '<C-\\><C-n>',
        'Enter normal mode in terminal')
    set_keymap('t', '<C-w>"', '<C-\\><C-n>:split<CR>',
        'Split terminal horizontally')
    set_keymap('t', '<C-w>%', '<C-\\><C-n>:vsplit<CR>',
        'Split terminal vertically')
end

--[[
 * @brief Sets up terminal autocommands
 * @local
 *
 * These autocommands ensure terminals behave consistently and integrate
 * well with the rest of Neovim. They handle events like terminal creation
 * and buffer management.
--]]
local function setup_autocommands()
    local group = vim.api.nvim_create_augroup("ToggleTermConfig", { clear = true })

    vim.api.nvim_create_autocmd("TermOpen", {
        group = group,
        pattern = "term://*",
        callback = function(args)
            -- Start in insert mode
            vim.cmd("startinsert")
            -- Set terminal-specific options
            vim.wo[args.buf].number = false
            vim.wo[args.buf].relativenumber = false
            vim.wo[args.buf].signcolumn = "no"
            vim.wo[args.buf].statusline = "%{b:term_title}"
        end,
    })
end

--[[
 * @brief Main setup function for the terminal component
 * @param opts table Configuration options from main setup
 *
 * This function initializes the terminal system, creating the necessary
 * commands and keymaps for terminal management. It ensures terminals
 * are easily accessible and behave consistently.
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    local config = vim.tbl_deep_extend("force", default_config, opts or {})

    -- Initialize toggleterm with our configuration
    require("toggleterm").setup({
        -- Shell configuration
        shell = config.shell,

        -- Behavior settings
        close_on_exit = config.behavior.close_on_exit,
        start_in_insert = config.behavior.start_in_insert,
        insert_mappings = config.behavior.insert_mappings,
        terminal_mappings = config.behavior.terminal_mappings,
        persist_size = config.behavior.persist_size,
        persist_mode = config.behavior.persist_mode,

        -- Appearance settings
        shade_terminals = false,
        highlights = config.visual.highlights,

        -- Float settings for default floating terminal
        float_opts = {
            border = config.layouts.floating.border,
            winblend = config.layouts.floating.winblend,
        },
    })

    -- Create terminal instances for different layouts
    local terms = {
        floating = create_terminal("floating", config),
        horizontal = create_terminal("horizontal", config),
        vertical = create_terminal("vertical", config),
    }

    -- Set up keymaps if provided
    if config.keymaps then
        -- Toggle floating terminal
        if config.keymaps.term_float then
            vim.keymap.set({"n", "t"}, config.keymaps.term_float,
                function() terms.floating:toggle() end,
                { desc = "Toggle floating terminal" })
        end

        -- Toggle horizontal terminal
        if config.keymaps.term_horizontal then
            vim.keymap.set({"n", "t"}, config.keymaps.term_horizontal,
                function() terms.horizontal:toggle() end,
                { desc = "Toggle horizontal terminal" })
        end

        -- Toggle vertical terminal
        if config.keymaps.term_vertical then
            vim.keymap.set({"n", "t"}, config.keymaps.term_vertical,
                function() terms.vertical:toggle() end,
                { desc = "Toggle vertical terminal" })
        end
    end

    -- Set up terminal-specific keymaps
    setup_keymaps(terms, config)

    -- Set up autocommands
    setup_autocommands()

    -- Store terminals for potential later access
    M.terminals = terms
end

return M
