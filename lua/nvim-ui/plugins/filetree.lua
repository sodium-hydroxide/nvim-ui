return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local function on_attach(bufnr)
            local api = require('nvim-tree.api')

            local function opts(desc)
                return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            -- default mappings
            api.config.mappings.default_on_attach(bufnr)

            -- custom mappings
            vim.keymap.set('n', '<leader><CR>', api.tree.change_root_to_node, opts('CD'))
            -- Optional: Add a mapping to return to root
            vim.keymap.set('n', '<leader>r', api.tree.change_root_to_parent, opts('Up'))
        end

        require("nvim-tree").setup({
            sort_by = "case_sensitive",
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true,
                icons = {
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                        modified = true,
                    },
                    modified_placement = "after",
                    glyphs = {
                        modified = "●",
                    },
                },
                highlight_opened_files = "all",
            },
            filters = {
                dotfiles = false,
            },
            git = {
                enable = true,
                ignore = false,
            },
            actions = {
                open_file = {
                    quit_on_open = false,
                },
                change_dir = {
                    enable = true,
                    global = false,
                },
            },
            on_attach = on_attach,
        })

        vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
}

