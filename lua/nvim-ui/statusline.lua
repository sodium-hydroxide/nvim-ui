--[[
 * @brief Manages statusline using lualine
 * @module nvim-ui.statusline
 *
 * This module provides a sophisticated statusline through lualine integration.
 * It configures sections, components, and themes while maintaining
 * consistency with the overall UI design.
--]]
local M = {}

--[[
 * @brief Default statusline configuration
 * @field theme Statusline theme settings
 * @field sections Content for each statusline section
 * @field extensions Special handling for certain filetypes
 * @local
--]]
local default_config = {
    -- Theme configuration
    theme = "auto",    -- Use colorscheme-based theme

    -- Component options
    component_separators = { left = "", right = ""},
    section_separators = { left = "", right = ""},

    -- Disable certain filetypes
    disabled_filetypes = {
        statusline = {},
        winbar = {},
    },

    -- Whether to show the statusline globally
    global_status = false,

    -- Configure sections
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
                padding = { left = 1, right = 1 },
            },
        },
        lualine_c = {
            {
                "filename",
                file_status = true,
                path = 1,  -- Relative path
                symbols = {
                    modified = "●",
                    readonly = "",
                    unnamed = "[No Name]",
                },
            },
        },
        lualine_x = {
            {
                "filetype",
                colored = true,
                icon_only = false,
                padding = { left = 1, right = 1 },
            },
            {
                "encoding",
                padding = { left = 1, right = 0 },
            },
            {
                "fileformat",
                symbols = {
                    unix = "LF",
                    dos = "CRLF",
                    mac = "CR",
                },
                padding = { left = 1, right = 1 },
            },
        },
        lualine_y = {
            {
                "progress",
                padding = { left = 1, right = 1 },
            },
        },
        lualine_z = {
            {
                "location",
                padding = { left = 1, right = 1 },
            },
        },
    },

    -- Inactive window sections
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },

    -- Extension-specific configs
    extensions = {
        "nvim-tree",
        "toggleterm",
        "quickfix",
    },
}

--[[
 * @brief Main setup function for the statusline
 * @param opts table Configuration options from main setup
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    local config = vim.tbl_deep_extend("force", default_config, opts or {})

    -- Initialize lualine
    require("lualine").setup(config)
end

return M
