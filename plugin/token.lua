vim.api.nvim_create_user_command('TokenCompile', function()
  require('token.compile').compile()
end, { desc = 'Compile token colorscheme for faster loading' })
