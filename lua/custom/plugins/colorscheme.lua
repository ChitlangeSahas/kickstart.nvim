return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- load before other plugins
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha', -- latte, frappe, macchiato, mocha
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
        },
      }

      vim.cmd.colorscheme 'catppuccin'
    end,
  },
}
