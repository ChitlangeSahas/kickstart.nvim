return {
  'coder/claudecode.nvim',
  branch = 'main',
  version = false,
  -- Pinned: the config below patches plugin internals. See the TODO by
  -- `resolve_inline_as_saved`. Bump deliberately, then re-check that patch.
  commit = '2390c6e45c4789072c293ac69de051d169668b29',
  dependencies = { 'folke/snacks.nvim' },
  -- Route the CLI through caveman so sessions get compressed tool output
  opts = {
    terminal_cmd = 'caveman claude',
    -- One buffer with +/- lines instead of two panes side by side. The split
    -- layout leaves ~40 columns per side next to the terminal, which wraps
    -- every real line of C.
    terminal = {
      split_side = 'right',
      split_width_percentage = 0.4,
    },
    diff_opts = {
      layout = 'unified',
      -- The plugin otherwise re-applies its own terminal width every time the
      -- terminal is focused or a diff opens and closes, undoing a manual drag.
      auto_resize_terminal = false,
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

    -- Which file the open diff is about and where its first change is, so
    -- ClaudeCodeDiffClosed can show that spot once the diff goes away. Closed
    -- carries neither.
    --
    -- The plugin parks the diff cursor on the first line whose type is not
    -- "unchanged". Every line above it is unchanged by definition, so that
    -- index is the same in the file as in the diff.
    local last_diff_file
    local last_diff_line

    -- The plugin only lays diffs out as splits. Float the window it just made,
    -- centred and large, so a review is one focused surface instead of a strip
    -- squeezed between the file and the terminal. Accept and deny still work:
    -- the buffer and window handles are unchanged, only the geometry moves.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'ClaudeCodeDiffOpened',
      callback = function(args)
        last_diff_file = args.data and args.data.file_path

        local win = args.data and args.data.diff_window
        if not win or not vim.api.nvim_win_is_valid(win) then
          return
        end

        local ok, cursor = pcall(vim.api.nvim_win_get_cursor, win)
        last_diff_line = ok and cursor[1] or nil

        local width = math.floor(vim.o.columns * 0.85)
        local height = math.floor(vim.o.lines * 0.85)

        -- Path relative to the cwd, so the title says which file without
        -- spending half the border on a home directory prefix.
        local path = args.data.file_path or ''
        local title = path ~= '' and vim.fn.fnamemodify(path, ':.') or 'diff'

        pcall(vim.api.nvim_win_set_config, win, {
          relative = 'editor',
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          border = 'rounded',
          title = ' ' .. title .. ' ',
          title_pos = 'center',
        })
        pcall(vim.api.nvim_set_current_win, win)
      end,
    })

    -- The unified diff buffer ships read-only: accept reads the snapshot taken
    -- when the diff opened, not the buffer, so any edit would be silently
    -- discarded. Refresh that snapshot from the live buffer first and the
    -- buffer can be unlocked.
    --
    -- The +/- markers live in a parallel line_types array built at open, so an
    -- edited buffer has to be realigned against it or the wrong lines get kept.
    -- `vim.diff` does that alignment: untouched lines keep their type, an
    -- equal-length rewrite keeps the type of the line it replaced, and anything
    -- else counts as new text to keep. Lines you insert are kept; the `-` lines
    -- are still dropped.
    -- TODO: this monkey-patches plugin internals, written against
    -- v0.3.0-53-g2390c6e (2390c6e4, 2026-06-25), the commit pinned in
    -- lazy-lock.json. `resolve_inline_as_saved` and `diff_data.new_buffer` are
    -- both private: a renamed function fails loudly at startup, but a renamed
    -- field fails silently and edits go back to being discarded. If editing a
    -- diff stops sticking after an update, look here first. Drop this once
    -- claudecode.nvim supports editable unified diffs upstream.
    local inline = require 'claudecode.diff_inline'
    local resolve_as_saved = inline.resolve_inline_as_saved

    -- Walks the hunks `vim.diff` reports between the rendered lines and the
    -- edited ones, returning a line_types array for the edited buffer.
    local function realign_types(lines, line_types, live)
      local hunks = vim.diff(table.concat(lines, '\n') .. '\n', table.concat(live, '\n') .. '\n', { result_type = 'indices' })

      if not hunks then
        return nil
      end

      local types = {}
      local old_line, new_line = 1, 1

      for _, hunk in ipairs(hunks) do
        local old_start, old_count, _, new_count = hunk[1], hunk[2], hunk[3], hunk[4]

        -- A pure insertion reports the line it follows rather than one it
        -- covers, so the untouched run reaches one line further.
        local stop = old_count > 0 and old_start or old_start + 1

        while old_line < stop do
          types[new_line] = line_types[old_line]
          old_line, new_line = old_line + 1, new_line + 1
        end

        for offset = 0, new_count - 1 do
          -- Same number of lines in and out means every one replaces a line
          -- whose role is known, which is the in-place edit case.
          types[new_line + offset] = old_count == new_count and line_types[old_line + offset] or 'added'
        end

        old_line, new_line = old_line + old_count, new_line + new_count
      end

      while new_line <= #live do
        types[new_line] = line_types[old_line]
        old_line, new_line = old_line + 1, new_line + 1
      end

      return types
    end

    inline.resolve_inline_as_saved = function(tab_name, diff_data)
      local buf = diff_data and diff_data.new_buffer

      if buf and vim.api.nvim_buf_is_valid(buf) then
        local live = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local types = realign_types(diff_data.lines, diff_data.line_types, live)

        if types then
          diff_data.lines, diff_data.line_types = live, types
        else
          vim.notify('claudecode: could not realign the edited diff, accepting the original', vim.log.levels.WARN)
        end
      end

      return resolve_as_saved(tab_name, diff_data)
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'ClaudeCodeDiffOpened',
      callback = function(args)
        local buf = args.data and args.data.diff_window and vim.api.nvim_win_get_buf(args.data.diff_window)

        if buf and vim.b[buf].claudecode_inline_diff then
          vim.bo[buf].modifiable = true
        end
      end,
    })

    -- The window the diff floated over, i.e. the first ordinary editor window
    -- in this tab: not a float, not the terminal.
    local function editor_window()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)

        if config.relative == '' and vim.bo[buf].buftype == '' then
          return win
        end
      end
    end

    -- Accepting or denying a diff leaves the cursor in the file, so the next
    -- prompt needs a manual hop back. Show the file that was just reviewed and
    -- return focus to Claude. Skipped when one diff replaced another, where
    -- focus belongs on the new diff.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'ClaudeCodeDiffClosed',
      callback = function(args)
        local reason = args.data and args.data.reason or ''
        if reason:match('^replaced') or reason:match('^setup failed') then
          return
        end

        local path, line = last_diff_file, last_diff_line
        last_diff_file, last_diff_line = nil, nil

        vim.schedule(function()
          -- Focus first: :edit fires a long chain of autocmds, and running it
          -- beforehand was enough to lose the terminal buffer, after which
          -- ClaudeCodeFocus spawns a second Claude instead of returning to the
          -- one that is already there.
          pcall(vim.cmd, 'ClaudeCodeFocus')

          local win = path and editor_window()

          -- Edited from that window rather than the current one, so the cursor
          -- stays where ClaudeCodeFocus just put it.
          if win then
            vim.api.nvim_win_call(win, function()
              if not pcall(vim.cmd.edit, path) then
                return
              end

              -- Clamped: a denied deletion at the end of a file leaves the
              -- recorded line past the last one.
              local target = math.min(line or 1, vim.api.nvim_buf_line_count(0))

              pcall(vim.api.nvim_win_set_cursor, win, { target, 0 })
              -- zz from inside win_call, so it centres that window rather than
              -- the terminal the cursor is really in.
              vim.cmd 'normal! zz'
            end)
          end
        end)
      end,
    })

    -- A terminal window only auto-follows its output while the cursor is on the
    -- last line. Leaving the window drops terminal-mode for normal mode and
    -- leaves the cursor behind, so output scrolls past it and the view sits
    -- half way up until you click back in. Park the cursor at the end on the
    -- way out and it keeps following.
    vim.api.nvim_create_autocmd({ 'TermLeave', 'WinLeave' }, {
      callback = function(args)
        if vim.bo[args.buf].buftype ~= 'terminal' then
          return
        end

        local win = vim.fn.bufwinid(args.buf)
        if win ~= -1 then
          pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(args.buf), 0 })
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
