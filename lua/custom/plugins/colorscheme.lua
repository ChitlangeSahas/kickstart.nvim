return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- load before other plugins
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha', -- latte, frappe, macchiato, mocha
        color_overrides = {
          mocha = {
            base = '#11111a',
            mantle = '#0d0d14',
            crust = '#090910',
          },
        },
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
  -- {
  --   'rebelot/kanagawa.nvim',
  --   priority = 1000, -- load before other plugins
  --   config = function()
  --     require('kanagawa').setup {
  --       theme = 'dragon',
  --       transparent = true,
  --       colors = {
  --         theme = {
  --           all = {
  --             ui = {
  --               bg_gutter = 'none',
  --             },
  --           },
  --         },
  --       },
  --       overrides = function(colors)
  --         local theme = colors.theme
  --
  --         return {
  --           TelescopeTitle = { fg = theme.ui.special, bold = true },
  --           TelescopePromptNormal = { bg = theme.ui.bg_p1 },
  --           TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
  --           TelescopePromptPrefix = { fg = theme.syn.identifier, bg = theme.ui.bg_p1 },
  --           TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
  --           TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
  --           TelescopePreviewNormal = { bg = theme.ui.bg_dim },
  --           TelescopePreviewBorder = { fg = theme.ui.bg_dim, bg = theme.ui.bg_dim },
  --           TelescopeSelection = { fg = theme.ui.fg, bg = theme.ui.bg_p2, bold = true },
  --           TelescopeSelectionCaret = { fg = theme.syn.identifier, bg = theme.ui.bg_p2 },
  --           TelescopeMatching = { fg = theme.syn.special1, bold = true },
  --         }
  --       end,
  --     }
  --
  --     vim.cmd.colorscheme 'kanagawa-dragon'
  --   end,
  -- },
  -- {
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- load before other plugins
  --   config = function()
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('tokyonight').setup {
  --       style = 'night', -- night, storm, moon, day
  --       styles = {
  --         comments = { italic = false },
  --         sidebars = 'dark',
  --         floats = 'dark',
  --       },
  --       on_colors = function(colors)
  --         colors.bg = '#11121a'
  --         colors.bg_dark = '#0d0e14'
  --         colors.bg_float = '#0d0e14'
  --         colors.bg_sidebar = '#0d0e14'
  --         colors.bg_statusline = '#0d0e14'
  --       end,
  --     }
  --
  --     vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },
}
