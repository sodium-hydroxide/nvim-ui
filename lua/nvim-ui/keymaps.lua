-- keymaps.lua for nvim-ui
--[[
 * @brief Manages all keybindings for the UI package
 * @module nvim-ui.keymaps
 *
 * This module provides a centralized system for managing keybindings.
 * It integrates with which-key to provide discoverable commands with
 * helpful descriptions.
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
            { "<leader>ff", ":Telescope find_files<CR>", desc = "Find files" },
            { "<leader>fg", ":Telescope live_grep<CR>", desc = "Live grep" },
            { "<leader>fb", ":Telescope buffers<CR>", desc = "Find buffers" },
            { "<leader>fr", ":Telescope oldfiles<CR>", desc = "Recent files" },

            -- Tree operations
            { "<leader>e", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
            { "<leader>o", ":NvimTreeFocus<CR>", desc = "Focus file tree" },
        }
    },

    -- Terminal commands
    terminal = {
        enabled = true,
        bindings = {
            { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
            { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
        }
    },

    -- Window management
    windows = {
        enabled = true,
        bindings = {
            { "<C-h>", "<C-w>h", desc = "Move to left window" },
            { "<C-j>", "<C-w>j", desc = "Move to bottom window" },
            { "<C-k>", "<C-w>k", desc = "Move to top window" },
            { "<C-l>", "<C-w>l", desc = "Move to right window" },
            { "<leader>w|", "<C-w>v", desc = "Split window right" },
            { "<leader>w-", "<C-w>s", desc = "Split window below" },
            { "<leader>w=", "<C-w>=", desc = "Equal window width" },
            { "<leader>wc", ":close<CR>", desc = "Close window" },
        }
    },

    -- Buffer management
    buffers = {
        enabled = true,
        bindings = {
            { "<leader>bd", ":bdelete<CR>", desc = "Delete buffer" },
            { "<leader>bn", ":bnext<CR>", desc = "Next buffer" },
            { "<leader>bp", ":bprevious<CR>", desc = "Previous buffer" },
            { "<leader>bD", ":bufdo bdelete<CR>", desc = "Delete all buffers" },
        }
    },

    -- Code and LSP commands
    code = {
        enabled = true,
        bindings = {
            { "gd", vim.lsp.buf.definition, desc = "Go to definition" },
            { "gr", vim.lsp.buf.references, desc = "Find references" },
            { "K", vim.lsp.buf.hover, desc = "Show hover" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code actions" },
            { "<leader>rn", vim.lsp.buf.rename, desc = "Rename symbol" },
            { "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
            { "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
            { "<leader>cf", vim.lsp.buf.format, desc = "Format code" },
        }
    },

    -- Search and replace
    search = {
        enabled = true,
        bindings = {
            { "<leader>sw", ":lua require('telescope.builtin').grep_string()<CR>", desc = "Search word" },
            { "<leader>sr", ":%s/<C-r><C-w>//g<Left><Left>", desc = "Replace word" },
            { "<leader>sc", ":nohlsearch<CR>", desc = "Clear search" },
        }
    },
}

--[[
 * @brief Applies a single keymap with error handling
 * @param mode string|table The mode(s) for the mapping
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
        { "<leader>f", group = "file" },
        { "<leader>t", group = "terminal" },
        { "<leader>w", group = "window" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>s", group = "search" },
    })

    -- Register all bindings with which-key
    wk.register(bindings)
end

--[[
 * @brief Processes and applies keymaps for a category
 * @param category table The category configuration
 * @param opts table Global options that affect keymaps
 * @local
--]]
local function apply_category_maps(category)
    if not category.enabled then
        return
    end

    for _, binding in ipairs(category.bindings) do
        local lhs, rhs, opts = binding[1], binding[2], { desc = binding.desc }
        safe_map("n", lhs, rhs, opts)
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

    -- Create a flat list of all bindings for which-key
    local all_bindings = {}
    for _, category in pairs(config) do
        if type(category) == "table" and category.bindings then
            vim.list_extend(all_bindings, category.bindings)
        end
    end

    -- Set up which-key integration
    setup_which_key(all_bindings)

    -- Apply keymaps by category
    for category_name, category in pairs(config) do
        if type(category) == "table" and category.bindings then
            apply_category_maps(category)
        end
    end
end

return M
