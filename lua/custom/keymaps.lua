print 'Loading keymaps.lua'

vim.keymap.set({ 'n', 'v' }, 'x', '"_x', { desc = 'Delete char without yanking' })
vim.keymap.set({ 'n', 'v' }, 'X', '"_X', { desc = 'Delete char backward without yanking' })
