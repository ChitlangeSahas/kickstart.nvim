local cmd = { 'clangd', '--background-index', '--clang-tidy' }

local gcc = '/opt/nordic/ncs/toolchains/185bb0e3b6/opt/zephyr-sdk/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc'
if vim.fn.filereadable(gcc) == 1 then
  table.insert(cmd, '--query-driver=' .. gcc)
end

return { cmd = cmd }
