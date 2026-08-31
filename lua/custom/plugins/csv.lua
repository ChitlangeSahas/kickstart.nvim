return {
  'hat0uma/csvview.nvim',
  ft = { 'csv', 'tsv' },
  cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  opts = {
    view = {
      display_mode = 'border', -- draw column separators
      header_lnum = 1, -- keep the header row pinned while scrolling
    },
    keymaps = {
      textobject_field_inner = { 'if', mode = { 'o', 'x' } },
      textobject_field_outer = { 'af', mode = { 'o', 'x' } },
      jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
      jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
    },
  },
  config = function(_, opts)
    require('csvview').setup(opts)
    -- render automatically instead of typing :CsvViewEnable every time
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'csv', 'tsv' },
      callback = function()
        vim.cmd 'CsvViewEnable'
      end,
    })
  end,
}
