return {
  'mfussenegger/nvim-jdtls',
  ft = 'java', -- Only load when opening Java files
  config = function()
    -- This function runs when the plugin loads (i.e., when you open a .java file)

    local jdtls = require 'jdtls'

    -- Determine OS
    local config = 'config_linux'
    if vim.fn.has 'mac' == 1 then
      config = 'config_mac'
    elseif vim.fn.has 'win32' == 1 then
      config = 'config_win'
    end

    -- Paths
    local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
    local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    -- Workspace per project
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

    local config_obj = {
      cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        launcher,
        '-configuration',
        jdtls_path .. '/' .. config,
        '-data',
        workspace_dir,
      },

      root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = 'fernflower' },
        },
      },

      init_options = {
        bundles = {},
      },
    }

    jdtls.start_or_attach(config_obj)
  end,
}
