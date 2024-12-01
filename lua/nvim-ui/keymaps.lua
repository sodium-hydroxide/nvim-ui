--[[
 * @brief Manages all keybindings for the UI package
 * @module nvim-ui.keymaps
 *
 * This module provides a centralized system for managing keybindings.
 * It organizes bindings by category and integrates with which-key
 * to provide discoverable commands with helpful descriptions.
--]]
local M = {}

--[[
 * @brief Default keymap configuration
 * @field leader The main leader key for commands
 * @field categories Groups of related commands
 * @local
--]]
local default_config = {
    -- Main leader key
    leader = " ",

    -- File and navigation commands
    files = {
        enabled = true,
        mappings = {
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
        mappings = {
            { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
            { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
        }
    },

    -- Window management
    windows = {
        enabled = true,
        mappings = {
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
        mappings = {
            { "<leader>bd", ":bdelete<CR>", desc = "Delete buffer" },
            { "<leader>bn", ":bnext<CR>", desc = "Next buffer" },
            { "<leader>bp", ":bprevious<CR>", desc = "Previous buffer" },
            { "<leader>bD", ":bufdo bdelete<CR>", desc = "Delete all buffers" },
        }
    },

    -- Code and LSP commands
    code = {
        enabled = true,
        mappings = {
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
        mappings = {
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
 * @param mappings table The keymap mappings to register
 * @local
--]]
local function setup_which_key(mappings)
    local ok, wk = pcall(require, "which-key")
    if not ok then
        return
    end

    -- Register which-key groups using new format
    wk.register({
        { "<leader>f", group = "file" },
        { "<leader>t", group = "terminal" },
        { "<leader>w", group = "window" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>s", group = "search" },
    })

    -- Register all mappings with which-key
    wk.register(mappings)
end

--[[
 * @brief Processes and applies keymaps for a category
 * @param category table The category configuration
 * @param all_mappings table Table to collect all mappings for which-key
 * @local
--]]
local function apply_category_maps(category, all_mappings)
    if not category.enabled then
        return
    end

    for _, mapping in ipairs(category.mappings) do
        local lhs, rhs, opts = mapping[1], mapping[2], { desc = mapping.desc }
        safe_map("n", lhs, rhs, opts)
        table.insert(all_mappings, mapping)
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

    -- Collect all mappings for which-key
    local all_mappings = {}

    -- Apply keymaps by category and collect them
    for category_name, category in pairs(config) do
        if type(category) == "table" and category.mappings then
            apply_category_maps(category, all_mappings)
        end
    end

    -- Set up which-key integration with all collected mappings
    setup_which_key(all_mappings)
end

return M
