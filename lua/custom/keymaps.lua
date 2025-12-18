print 'Loading keymaps.lua'

vim.keymap.set({ 'n', 'v' }, 'x', '"_x', { desc = 'Delete char without yanking' })
vim.keymap.set({ 'n', 'v' }, 'X', '"_X', { desc = 'Delete char backward without yanking' })

-- U for redo (u is undo, U is redo - makes sense!)
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })

-- Then you can use R for rename
vim.keymap.set('n', 'R', vim.lsp.buf.rename, { desc = 'Rename symbol' })

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find project files' })
vim.keymap.set('n', '<leader>ff', builtin.git_files, { desc = 'Telescope find git files' })
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string { search = vim.fn.input 'Grep Search in project files > ' }
end, { desc = 'Telescope grep search in project files' })
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
