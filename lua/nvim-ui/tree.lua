--[[
 * @brief Manages file tree visualization and navigation
 * @module nvim-ui.tree
 *
 * This module provides a carefully configured file tree interface using nvim-tree.
 * It focuses on making file navigation intuitive while providing powerful features
 * like git integration and file operations. The configuration emphasizes:
 *
 * - Clean, informative display with icons and git status
 * - Intuitive keymaps for navigation and file operations
 * - Smart handling of window positioning and focus
 * - Consistent behavior with buffer management
--]]
local M = {}

--[[
 * @brief Default tree configuration
 * @field view Settings for tree appearance and behavior
 * @field git Settings for git status display
 * @field actions Settings for file operations
 * @local
 *
 * This configuration aims to provide a balance between features and simplicity.
 * Each setting is chosen to support efficient file navigation while maintaining
 * a clean interface.
--]]
local default_config = {
    -- Core settings
    sort = {
        sorter = "name",
        folders_first = true,
    },

    -- View configuration controls how the tree is displayed
    view = {
        width = {
            min = 30,
            max = 50,
            padding = 1,
        },
        side = "left",
        number = false,
        relativenumber = false,
        signcolumn = "yes",
        float = {
            enable = false,
            quit_on_focus_loss = true,
            open_win_config = {
                relative = "editor",
                border = "rounded",
                width = 30,
                height = 30,
                row = 1,
                col = 1,
            },
        },
    },

    -- Git integration shows status and changes
    git = {
        enable = true,
        ignore = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
        timeout = 400,
    },

    -- Renderer controls visual elements
    renderer = {
        add_trailing = false,
        group_empty = true,
        highlight_git = true,
        full_name = false,
        highlight_opened_files = "none",
        root_folder_label = ":~:s?$?/..?",
        indent_width = 2,
        indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
                corner = "└",
                edge = "│",
                item = "│",
                bottom = "─",
                none = " ",
            },
        },
        icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
            },
            glyphs = {
                default = "",
                symlink = "",
                bookmark = "",
                folder = {
                    arrow_closed = "",
                    arrow_open = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
                git = {
                    unstaged = "✗",
                    staged = "✓",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "★",
                    deleted = "",
                    ignored = "◌",
                },
            },
        },
        special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
        symlink_destination = true,
    },

    -- Filters determine which files are shown
    filters = {
        dotfiles = false,
        git_clean = false,
        no_buffer = false,
        custom = {},
        exclude = {},
    },

    -- Actions configure behavior
    actions = {
        use_system_clipboard = true,
        change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
        },
        expand_all = {
            max_folder_discovery = 300,
            exclude = {},
        },
        file_popup = {
            open_win_config = {
                col = 1,
                row = 1,
                relative = "cursor",
                border = "shadow",
                style = "minimal",
            },
        },
        open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
                enable = true,
                chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                exclude = {
                    filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                    buftype = { "nofile", "terminal", "help" },
                },
            },
        },
    },

    -- System configuration
    system_open = {
        cmd = "",
        args = {},
    },

    -- Diagnostics configuration
    diagnostics = {
        enable = false,
        show_on_dirs = false,
        show_on_open_dirs = true,
        debounce_delay = 50,
        severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
        },
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        },
    },
}

--[[
 * @brief Sets up keymaps for tree navigation and operations
 * @param bufnr number Buffer number for the tree
 * @local
 *
 * These keymaps are designed to be intuitive and consistent with standard
 * Neovim operations while providing quick access to common tree functions.
--]]
local function setup_keymaps(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Navigation
    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
    vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
    vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))

    -- File operations
    vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
    vim.keymap.set("n", "a", api.fs.create, opts("Create"))
    vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
    vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
    vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
    vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
    vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))

    -- Tree operations
    vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
    vim.keymap.set("n", "q", api.tree.close, opts("Close"))

    -- Filters
    vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
    vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
    vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
end

--[[
 * @brief Sets up autocommands for tree behavior
 * @local
 *
 * These autocommands ensure the tree behaves consistently with the rest
 * of the editor, handling events like window resizing and buffer changes.
--]]
local function setup_autocommands()
    local group = vim.api.nvim_create_augroup("NvimTreeConfig", { clear = true })

    -- Open tree when opening a directory
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
        group = group,
        callback = function(data)
            local directory = vim.fn.isdirectory(data.file) == 1
            if directory then
                vim.cmd.cd(data.file)
                require("nvim-tree.api").tree.open()
            end
        end,
    })

    -- Resize tree on window resize
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = group,
        callback = function()
            local view = require("nvim-tree.view")
            if view.is_visible() then
                view.resize()
            end
        end,
    })
end

--[[
 * @brief Main setup function for the tree component
 * @param opts table Configuration options from main setup
--]]
M.setup = function(opts)
    -- Merge user options with defaults
    local config = vim.tbl_deep_extend("force", default_config, opts or {})

    -- Configure nvim-tree
    require("nvim-tree").setup(config)

    -- Set up autocommands
    setup_autocommands()

    -- Add buffer-local keymaps when tree is opened
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "NvimTree",
        callback = function(args)
            setup_keymaps(args.buf)
        end,
    })

    -- Set up global toggle keymap if provided
    if opts.keymaps and opts.keymaps.tree_toggle then
        vim.keymap.set("n", opts.keymaps.tree_toggle,
            "<cmd>NvimTreeToggle<CR>",
            { desc = "Toggle file tree" })
    end
end

return M
