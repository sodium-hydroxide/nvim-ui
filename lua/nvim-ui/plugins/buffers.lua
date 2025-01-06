return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require("bufferline").setup({
            options = {
                -- Enable close button
                close_command = "bdelete! %d",
                right_mouse_command = "bdelete! %d",
                left_mouse_command = "buffer %d",
                middle_mouse_command = nil,

                -- Styling
                indicator = {
                    icon = '▎', -- this should be omitted if indicator style is not 'icon'
                    style = 'icon',
                },
                buffer_close_icon = '',
                modified_icon = '●',
                close_icon = '',
                left_trunc_marker = '',
                right_trunc_marker = '',

                -- Configure bufferline to use LSP diagnostics
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,

                -- Customize appearance
                separator_style = "thin",
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = true,
                color_icons = true,

                -- Sort by
                sort_by = 'insert_after_current',

                -- Enforce regular tabs
                enforce_regular_tabs = false,

                -- Prevent auto-switching to new buffers
                show_tab_indicators = true,
            },
            -- You can add highlights if you want to change the colors
            highlights = {
                buffer_selected = {
                    bold = true,
                    italic = false,
                },
                diagnostic_selected = {
                    bold = true,
                    italic = false,
                },
                info_selected = {
                    bold = true,
                    italic = false,
                },
                info_diagnostic_selected = {
                    bold = true,
                    italic = false,
                },
            },
        })

        -- Keymaps for buffer navigation
        vim.keymap.set('n', '<leader>bp', ':BufferLinePick<CR>', { desc = 'Pick buffer' })
        vim.keymap.set('n', '<leader>bc', ':BufferLinePickClose<CR>', { desc = 'Pick buffer to close' })
        vim.keymap.set('n', '<S-h>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
        vim.keymap.set('n', '<S-l>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
        vim.keymap.set('n', '<leader>bl', ':BufferLineCloseLeft<CR>', { desc = 'Close all buffers to the left' })
        vim.keymap.set('n', '<leader>br', ':BufferLineCloseRight<CR>', { desc = 'Close all buffers to the right' })
        vim.keymap.set('n', '<leader>ba', ':BufferLineCloseOthers<CR>', { desc = 'Close all other buffers' })
    end
}

