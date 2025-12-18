print 'Loading keymaps.lua'

vim.keymap.set({ 'n', 'v' }, 'x', '"_x', { desc = 'Delete char without yanking' })
vim.keymap.set({ 'n', 'v' }, 'X', '"_X', { desc = 'Delete char backward without yanking' })

-- U for redo (u is undo, U is redo - makes sense!)
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })

-- Then you can use R for rename
vim.keymap.set('n', 'R', vim.lsp.buf.rename, { desc = 'Rename symbol' })
