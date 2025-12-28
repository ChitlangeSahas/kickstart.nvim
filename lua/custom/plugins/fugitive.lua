return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G' }, -- lazy-load on Git commands
    keys = {
      { '<leader>gg', '<cmd>Git<cr>', desc = 'Git status' },
      { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git commit' },
      { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
      { '<leader>gl', '<cmd>Git pull<cr>', desc = 'Git pull' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
      { '<leader>gd', '<cmd>Gvdiffsplit<cr>', desc = 'Git diff split' },
    },
  },
}
