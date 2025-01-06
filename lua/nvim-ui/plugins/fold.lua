return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    config = function()
        -- Fold options
        vim.o.foldcolumn = '1'    -- Show fold column
        vim.o.foldlevel = 99      -- High value to ensure folds are not closed by default
        vim.o.foldlevelstart = 99 -- High value to ensure folds are not closed when opening file
        vim.o.foldenable = true   -- Enable folding

        -- Keymaps
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds,
            { desc = "Open all folds" })

        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds,
            { desc = "Close all folds" })

        vim.keymap.set('n', 'zK', function()
            local winid = require('ufo').peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end, { desc = "Peek Fold" })

        -- Additional useful keymaps
        vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds,
            { desc = "Open folds except kinds" })

        vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith,
            { desc = "Close folds with" })

        -- UFO setup
        require('ufo').setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { 'lsp', 'indent' }
            end,
            -- Optional: Enable fold preview
            preview = {
                win_config = {
                    border = 'rounded',
                    winhighlight = 'Normal:Normal',
                    winblend = 0,
                },
            },
            -- Optional: Close fold when leaving
            close_fold_kinds = {},
        })
    end,
}

