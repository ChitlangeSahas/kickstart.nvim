local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets('all', {
  s('todo', {
    f(function()
      local cs = vim.bo.commentstring
      return cs:format(''):gsub('%s+', '') .. ' TODO: (sahas) '
    end),
    i(1, 'writeYourTodo'),
  }),
})
