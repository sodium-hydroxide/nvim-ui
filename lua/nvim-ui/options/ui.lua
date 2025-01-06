vim.opt.shortmess = "I"             --> Hide startup message
vim.opt.mouse = "a"                 --> Allow mouse to be used
vim.opt.mousemodel = "popup"        --> Hide mouse unless being used
vim.opt.number = true               --> show line numbers
vim.opt.relativenumber = false      --> use absolute numbering
vim.opt.syntax = "ON"               --> syntax highlighting
vim.opt.backup = false              --> supress generation of backup files
vim.opt.wrap = true                 --> wrap text

------  Set VI Paste Buffer
vim.opt.clipboard = unnamedplus
vim.keymap.set({'n', 'v'}, 'y', '"+y')
vim.keymap.set({'n', 'v'}, 'd', '"+d')
vim.keymap.set({'n', 'v'}, 'p', '"+p')

