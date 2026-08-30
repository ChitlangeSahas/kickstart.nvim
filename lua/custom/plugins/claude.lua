return {
  'coder/claudecode.nvim',
  branch = 'main',
  version = false,
  dependencies = { 'folke/snacks.nvim' },
  -- Route the CLI through caveman so sessions get compressed tool output
  opts = {
    terminal_cmd = 'caveman claude',
    -- One buffer with +/- lines instead of two panes side by side. The split
    -- layout leaves ~40 columns per side next to the terminal, which wraps
    -- every real line of C.
    diff_opts = {
      layout = 'unified',
      -- A new tab starts with an empty [No Name] window that the diff and the
      -- terminal then sit beside, so the leftmost third of the screen stays
      -- blank. Reusing the current tab avoids it.
      open_in_new_tab = false,
    },
  },
  config = function(_, opts)
    require('claudecode').setup(opts)

    -- `vim.o.confirm` turns closing a modified buffer into a "Save changes?"
    -- prompt. The proposed-changes buffer is always modified by design, and
    -- writing it is what ACCEPTS the diff, so replacing or closing one asks a
    -- question whose only safe answer is No. Clear the flag on those buffers,
    -- leaving <leader>aa and <leader>ad as the way to accept or deny. The
    -- plugin's own dirty check reads the real file's buffer, not this one.
    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'TextChanged', 'BufModifiedSet' }, {
      callback = function(args)
        if vim.b[args.buf].claudecode_diff_tab_name then
          vim.bo[args.buf].modified = false
        end
      end,
    })
  end,
  -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
  -- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
  -- spec defers loading until a <leader>a* mapping is pressed and the commands
  -- would not exist yet.
  cmd = {
    'ClaudeCode',
    'ClaudeCodeFocus',
    'ClaudeCodeSelectModel',
    'ClaudeCodeAdd',
    'ClaudeCodeSend',
    'ClaudeCodeTreeAdd',
    'ClaudeCodeStatus',
    'ClaudeCodeStart',
    'ClaudeCodeStop',
    'ClaudeCodeOpen',
    'ClaudeCodeClose',
    'ClaudeCodeDiffAccept',
    'ClaudeCodeDiffDeny',
    'ClaudeCodeCloseAllDiffs',
  },
  keys = {
    { '<leader>a', nil, desc = 'AI/Claude Code' },
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    -- Works from terminal mode too, so it jumps both ways without Esc
    { '<C-Space>', '<cmd>ClaudeCodeFocus<cr>', mode = { 'n', 't' }, desc = 'Toggle Claude focus' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    {
      '<leader>as',
      '<cmd>ClaudeCodeTreeAdd<cr>',
      desc = 'Add file',
      ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw', 'snacks_picker_list' },
    },
    -- Diff management
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
  },
}
