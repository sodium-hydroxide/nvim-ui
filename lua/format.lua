--[[
 * @brief Manages text formatting and visualization settings
 * @module nvim-ui.format
 *
 * This module handles automatic text formatting and visualization, including:
 * - Trailing whitespace removal
 * - Final newline management
 * - Extra newline cleanup
 * - Whitespace character visualization
 *
 * The formatting can be applied automatically on save or manually through commands.
 * Whitespace visualization helps maintain clean code by making spaces and tabs visible.
--]]
local M = {}

--[[
 * @brief Default formatting configuration
 * @field trim_whitespace Remove trailing whitespace
 * @field final_newline Ensure file ends with newline
 * @field max_blank_lines Maximum consecutive blank lines allowed
 * @field show_whitespace Show whitespace characters
 * @local
--]]
local default_config = {
    -- Formatting options
    trim_whitespace = true,
    final_newline = true,
    max_blank_lines = 2,
    format_on_save = true,

    -- Whitespace visualization
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
}

--[[
 * @brief Removes trailing whitespace from the current buffer
 * @param bufnr number Buffer number to format
 * @local
--]]
local function trim_trailing_whitespace(bufnr)
    -- Save cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Remove trailing whitespace
    vim.cmd([[keeppatterns %s/\s\+$//e]])

    -- Restore cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)
end

--[[
 * @brief Ensures file ends with exactly one newline
 * @param bufnr number Buffer number to format
 * @local
--]]
local function ensure_final_newline(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local count = #lines

    -- Remove trailing empty lines
    while count > 0 and lines[count] == "" do
        count = count - 1
    end

    -- Ensure exactly one final newline
    if count > 0 then
        lines = vim.list_slice(lines, 1, count)
        table.insert(lines, "")
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    end
end

--[[
 * @brief Removes excessive blank lines
 * @param bufnr number Buffer number to format
 * @param max_blank_lines number Maximum consecutive blank lines allowed
 * @local
--]]
local function clean_blank_lines(bufnr, max_blank_lines)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local result = {}
    local blank_count = 0

    for _, line in ipairs(lines) do
        if line:match("^%s*$") then
            blank_count = blank_count + 1
            if blank_count <= max_blank_lines then
                table.insert(result, line)
            end
        else
            blank_count = 0
            table.insert(result, line)
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result)
end

--[[
 * @brief Sets up whitespace visualization
 * @param opts table Configuration options
 * @local
--]]
local function setup_whitespace_display(opts)
    -- Enable whitespace visualization
    vim.opt.list = true

    -- Configure listchars
    local listchars = {}
    for key, value in pairs(opts.listchars) do
        listchars[key] = value
    end
    vim.opt.listchars = listchars
end

--[[
 * @brief Formats the current buffer according to settings
 * @param bufnr number Buffer number to format
 * @param opts table Configuration options
 * @local
--]]
local function format_buffer(bufnr, opts)
    -- Save window view
    local view = vim.fn.winsaveview()

    if opts.trim_whitespace then
        trim_trailing_whitespace(bufnr)
    end

    if opts.final_newline then
        ensure_final_newline(bufnr)
    end

    if opts.max_blank_lines then
        clean_blank_lines(bufnr, opts.max_blank_lines)
    end

    -- Restore window view
    vim.fn.winrestview(view)
end

--[[
 * @brief Sets up format-on-save functionality
 * @param opts table Configuration options
 * @local
--]]
local function setup_format_on_save(opts)
    vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            format_buffer(bufnr, opts)
        end
    })
end

--[[
 * @brief Creates user commands for manual formatting
 * @local
--]]
local function create_commands()
    -- Command to remove trailing whitespace
    vim.api.nvim_create_user_command("TrimWhitespace", function()
        trim_trailing_whitespace(0)
    end, { desc = "Remove trailing whitespace" })

    -- Command to ensure final newline
    vim.api.nvim_create_user_command("EnsureNewline", function()
        ensure_final_newline(0)
    end, { desc = "Ensure file ends with newline" })

    -- Command to clean up blank lines
    vim.api.nvim_create_user_command("CleanBlankLines", function()
        clean_blank_lines(0, M.options.max_blank_lines)
    end, { desc = "Clean up excessive blank lines" })

    -- Command to run all formatting
    vim.api.nvim_create_user_command("Format", function()
        format_buffer(0, M.options)
    end, { desc = "Run all configured formatting" })
end

--[[
 * @brief Sets up text formatting and visualization
 * @param opts table Configuration options from main setup
--]]
M.setup = function(opts)
    -- Merge with default config
    M.options = vim.tbl_deep_extend("force", default_config, opts or {})

    -- Set up whitespace visualization if enabled
    if M.options.show_whitespace then
        setup_whitespace_display(M.options)
    end

    -- Set up format-on-save if enabled
    if M.options.format_on_save then
        setup_format_on_save(M.options)
    end

    -- Create user commands
    create_commands()
end

return M
