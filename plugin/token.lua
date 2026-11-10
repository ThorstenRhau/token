vim.api.nvim_create_user_command('TokenCompile', function()
  require('token.compile').compile()
end, { desc = 'Compile token colorscheme for faster loading' })

vim.api.nvim_create_user_command('TokenClearCache', function()
  require('token.compile').clear()
end, { desc = 'Remove compiled token colorscheme caches' })
