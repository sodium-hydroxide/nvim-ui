local diagnostic_config = {
    -- Configure floating window appearance
    float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
        width = 80,
        wrap = true,
        focus = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    },

    -- Configure inline diagnostic appearance
    virtual_text = {
        prefix = '●',
        format = function(diagnostic)
            local message = diagnostic.message
            local source = diagnostic.source
            local code = diagnostic.code or
                        (diagnostic.user_data and
                         diagnostic.user_data.lsp and
                         diagnostic.user_data.lsp.code)

            -- We show a shorter message inline since users can press <leader>r for details
            if #message > 30 then
                message = string.sub(message, 1, 27) .. "..."
            end

            if code then
                return string.format("[%s] %s", code, message)
            end
            return message
        end,
        spacing = 4,
    },

    signs = {
        priority = 20,
        text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
        }
    },

    severity_sort = true,
    update_in_insert = false,
}

-- Apply the diagnostic configuration
vim.diagnostic.config(diagnostic_config)

-- Set up diagnostic keymaps
vim.keymap.set('n', '<leader>r', function()
    -- Create an enhanced floating window for diagnostics
    vim.diagnostic.open_float({
        border = "rounded",
        header = "Diagnostics:",
        source = "always",
        prefix = "",
        format = function(diagnostic)
            -- Format the full diagnostic message with more detail
            local message = diagnostic.message
            local source = diagnostic.source or "unknown"
            local code = diagnostic.code or
                        (diagnostic.user_data and
                         diagnostic.user_data.lsp and
                         diagnostic.user_data.lsp.code) or ""

            -- Include all available information in the detailed view
            if code ~= "" then
                return string.format("[%s] %s\nSource: %s", code, message, source)
            end
            return string.format("%s\nSource: %s", message, source)
        end,
        width = 80,
        wrap = true,
    })
end, { noremap = true, silent = true, desc = "Show diagnostic details" })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Next diagnostic" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Add diagnostics to location list" })

