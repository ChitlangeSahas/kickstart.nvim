-- LaTeX editing + live preview via VimTeX.
-- Requires: latexmk (ships with MacTeX) and Skim.app (PDF viewer with auto-reload).
return {
  {
    'lervag/vimtex',
    lazy = false, -- VimTeX docs recommend against lazy-loading
    init = function()
      -- Use Skim: it watches the PDF and auto-reloads on each recompile.
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1 -- forward search (source -> PDF) after compile
      vim.g.vimtex_view_skim_activate = 1 -- bring Skim to front on forward search

      -- latexmk drives continuous compilation (the "live" part).
      vim.g.vimtex_compiler_method = 'latexmk'

      -- Don't pop the quickfix window open for warnings (resumes throw a few).
      vim.g.vimtex_quickfix_open_on_warning = 0
    end,
  },
}
