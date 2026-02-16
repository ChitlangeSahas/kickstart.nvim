print 'java loading...'
local home = os.getenv 'HOME'
local workspace_path = home .. '/.local/share/nvim/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

local status, jdtls = pcall(require, 'jdtls')
if not status then
  return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities

local java_17_home = vim.fn.system('/usr/libexec/java_home -v 17'):gsub('\n', '')
local java_21_home = vim.fn.system('/usr/libexec/java_home -v 21'):gsub('\n', '')

local config = {
  cmd = {
    java_21_home .. '/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dosgi.bundles.excludes=org.eclipse.jdt.junit.*',
    '-Dorg.eclipse.jdt.ls.skipJunitDetection=true',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
    '-jar',
    vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    home .. '/.local/share/nvim/mason/packages/jdtls/config_mac',
    '-data',
    workspace_dir,
  },
  cmd_env = {
    JAVA_HOME = java_17_home, -- ADD THIS - force Gradle to use Java 17
  },
  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml' },

  on_init = function(client)
    -- Force Gradle to use Java 17
    client.config.settings.java.import.gradle.java.home = java_17_home
    client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  end,

  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = extendedClientCapabilities,
      maven = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'automatic',
        runtimes = {
          {
            name = 'JavaSE-17',
            path = java_17_home,
            default = true, -- PROJECT uses Java 17
          },
          {
            name = 'JavaSE-21',
            path = java_21_home,
          },
        },
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = 'all', -- literals, all, none
        },
      },
      format = {
        enabled = false,
      },
      import = {
        gradle = {
          java = {
            home = java_17_home, -- Force Gradle to use Java 17
          },
          jvmArguments = '-Dorg.gradle.java.home=' .. java_17_home,
          arguments = '-x checkstyleMain -x test -x integrationTest --no-daemon',
        },
      },
    },
  },

  init_options = {
    bundles = {},
  },
}
require('jdtls').start_or_attach(config)

vim.keymap.set('n', '<leader>co', "<Cmd>lua require'jdtls'.organize_imports()<CR>", { desc = 'Organize Imports' })
vim.keymap.set('n', '<leader>crv', "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = 'Extract Variable' })
vim.keymap.set('v', '<leader>crv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", { desc = 'Extract Variable' })
vim.keymap.set('n', '<leader>crc', "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = 'Extract Constant' })
vim.keymap.set('v', '<leader>crc', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", { desc = 'Extract Constant' })
vim.keymap.set('v', '<leader>crm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", { desc = 'Extract Method' })
