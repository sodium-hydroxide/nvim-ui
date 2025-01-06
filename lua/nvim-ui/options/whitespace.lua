------  Whitespace Handling
vim.opt.tabstop = 4                 --> 4 spaces for a tab
vim.opt.shiftwidth = 4              --> ''
vim.opt.expandtab = true            --> expand tabs to spaces
vim.opt.smartindent = true          --> indent files correctly
vim.opt.list = true                 --> render whitespace
vim.opt.listchars = {               --> specific whitespace to render
    tab = "»·",                     --> \t
    trail = "~",                    -->
    nbsp = "‡",                     -->
    extends = "›",                  -->
    precedes = "‹",                 -->
    space = "⋅",                    -->
    eol = "¬"                       -->
}
vim.opt.cursorline = true           --> Show cursor
vim.opt.fixendofline = true         -->
vim.opt.fixeol = true               -->
vim.opt.colorcolumn = "80"          --> Render at 80 char
vim.api.nvim_set_keymap(            --> Toggle Text Wrap
    'n',
    '<leader>w',
    ':set wrap!<CR>',
    { noremap = true, silent = true }
)

------  Handle Whitespace on Save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      -- Save cursor position
      local curpos = vim.api.nvim_win_get_cursor(0)
      -- Trim trailing whitespace
      vim.cmd([[%s/\s\+$//e]])
      -- Trim trailing newlines while ensuring single final newline
      -- Go to last line
      vim.cmd([[
        silent! %s/\($\n\s*\)\+\%$//e
        silent! call append(line('$'), '')
      ]])
      -- Restore cursor position
      vim.api.nvim_win_set_cursor(0, curpos)
    end,
  })

