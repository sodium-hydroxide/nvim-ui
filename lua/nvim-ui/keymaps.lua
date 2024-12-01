-- keymaps.lua for nvim-ui
--[[
 * @brief Manages all keybindings for the UI package
 * @module nvim-ui.keymaps
 *
 * This module provides a centralized system for managing keybindings.
 * It organizes bindings by category and integrates with which-key
 * to provide discoverable commands with helpful descriptions.
 *
 * The keybinding system emphasizes:
 * - Logical organization by function
 * - Consistent patterns across different tools
 * - Clear documentation of each command
 * - Easy customization by users
--]]
local M = {}

--[[
 * @brief Default keymap configuration
 * @field leader The main leader key for commands
 * @field categories Groups of related commands
 * @local
 *
 * This configuration creates a comprehensive set of keybindings
 * organized by their function. Each binding includes a clear
 * description and is grouped logically.
--]]
local default_config = {
    -- Main leader key
    leader = " ",

    -- File and navigation commands
    files = {
        enabled = true,
        bindings = {
            -- File operations
            ["<leader>ff"] = { ":Telescope find_files<CR>", "Find files" },
            ["<leader>fg"] = { ":Telescope live_grep<CR>", "Live grep" },
            ["<leader>fb"] = { ":Telescope buffers<CR>", "Find buffers" },
            ["<leader>fr"] = { ":Telescope oldfiles<CR>", "Recent files" },

            -- Tree operations
            ["<leader>e"] = { ":NvimTreeToggle<CR>", "Toggle file tree" },
            ["<leader>o"] = { ":NvimTreeFocus<CR>", "Focus file tree" },
        }
    },

    -- Terminal commands
    terminal = {
        enabled = true,
        bindings = {
            ["<C-\\>"] = { "<cmd>ToggleTerm<CR>", "Toggle terminal" },
            ["<leader>tf"] = { "<cmd>ToggleTerm direction=float<CR>", "Floating terminal" },
            ["<leader>th"] = { "<cmd>ToggleTerm direction=horizontal<CR>", "Horizontal terminal" },
            ["<leader>tv"] = { "<cmd>ToggleTerm direction=vertical<CR>", "Vertical terminal" },
        }
    },

    -- Window management
    windows = {
        enabled = true,
        bindings = {
            ["<C-h>"] = { "<C-w>h", "Move to left window" },
            ["<C-j>"] = { "<C-w>j", "Move to bottom window" },
            ["<C-k>"] = { "<C-w>k", "Move to top window" },
            ["<C-l>"] = { "<C-w>l", "Move to right window" },
            ["<leader>w|"] = { "<C-w>v", "Split window right" },
            ["<leader>w-"] = { "<C-w>s", "Split window below" },
            ["<leader>w="] = { "<C-w>=", "Equal window width" },
            ["<leader>wc"] = { ":close<CR>", "Close window" },
        }
    },

    -- Buffer management
    buffers = {
        enabled = true,
        bindings = {
            ["<leader>bd"] = { ":bdelete<CR>", "Delete buffer" },
            ["<leader>bn"] = { ":bnext<CR>", "Next buffer" },
            ["<leader>bp"] = { ":bprevious<CR>", "Previous buffer" },
            ["<leader>bD"] = { ":bufdo bdelete<CR>", "Delete all buffers" },
        }
    },

    -- Code and LSP commands
    code = {
        enabled = true,
        bindings = {
            ["gd"] = { vim.lsp.buf.definition, "Go to definition" },
            ["gr"] = { vim.lsp.buf.references, "Find references" },
            ["K"] = { vim.lsp.buf.hover, "Show hover" },
            ["<leader>ca"] = { vim.lsp.buf.code_action, "Code actions" },
            ["<leader>rn"] = { vim.lsp.buf.rename, "Rename symbol" },
            ["[d"] = { vim.diagnostic.goto_prev, "Previous diagnostic" },
            ["]d"] = { vim.diagnostic.goto_next, "Next diagnostic" },
            ["<leader>cf"] = { vim.lsp.buf.format, "Format code" },
        }
    },

    -- Search and replace
    search = {
        enabled = true,
        bindings = {
            ["<leader>sw"] = { ":lua require('telescope.builtin').grep_string()<CR>", "Search word" },
            ["<leader>sr"] = { ":%s/<C-r><C-w>//g<Left><Left>", "Replace word" },
            ["<leader>sc"] = { ":nohlsearch<CR>", "Clear search" },
        }
    },
}

--[[
 * @brief Applies a single keymap with error handling
 * @param mode string|table The mode(s) for the keymap
 * @param lhs string The left-hand side of the mapping
 * @param rhs string|function The right-hand side of the mapping
 * @param opts table Additional options for the mapping
 * @local
--]]
local function safe_map(mode, lhs, rhs, opts)
    local ok, err = pcall(vim.keymap.set, mode, lhs, rhs, opts)
    if not ok then
        vim.notify(
            string.format("Error setting keymap %s: %s", lhs, err),
            vim.log.levels.ERROR
        )
    end
end

--[[
 * @brief Sets up which-key integration
 * @param bindings table The keymap bindings to register
 * @local
--]]
local function setup_which_key(bindings)
    local ok, wk = pcall(require, "which-key")
    if not ok then
        return
    end

    -- Register which-key groups
    wk.register({
        ["<leader>f"] = { name = "+file" },
        ["<leader>t"] = { name = "+terminal" },
        ["<leader>w"] = { name = "+window" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>s"] = { name = "+search" },
    })

    -- Register all bindings with which-key
    for lhs, mapping in pairs(bindings) do
        local rhs, desc = mapping[1], mapping[2]
        wk.register({ [lhs] = { rhs, desc } })
    end
end

--[[
 * @brief Processes and applies keymaps for a category
 * @param category table The category configuration
 * @param opts table Global options that affect keymaps
 * @local
--]]
local function apply_category_maps(category, opts)
    if not category.enabled then
        return
    end

    for lhs, mapping in pairs(category.bindings) do
        local rhs, desc = mapping[1], mapping[2]
        safe_map("n", lhs, rhs, {
            desc = desc,
            silent = true,
            noremap = true
        })
    end
end

--[[
 * @brief Main setup function for keymaps
 * @param opts table Configuration options from main setup
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    local config = vim.tbl_deep_extend("force", default_config, opts or {})

    -- Set leader key
    vim.g.mapleader = config.leader

    -- Create a flat map of all bindings for which-key
    local all_bindings = {}
    for category_name, category in pairs(config) do
        if type(category) == "table" and category.bindings then
            for lhs, mapping in pairs(category.bindings) do
                all_bindings[lhs] = mapping
            end
        end
    end

    -- Set up which-key integration
    setup_which_key(all_bindings)

    -- Apply keymaps by category
    for category_name, category in pairs(config) do
        if type(category) == "table" and category.bindings then
            apply_category_maps(category, config)
        end
    end
end

return M
