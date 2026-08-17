local repo = assert(vim.env.TOKEN_CAPTURE_REPO, 'TOKEN_CAPTURE_REPO is required')
local scheme = assert(vim.env.TOKEN_CAPTURE_SCHEME, 'TOKEN_CAPTURE_SCHEME is required')
local background = assert(vim.env.TOKEN_CAPTURE_BACKGROUND, 'TOKEN_CAPTURE_BACKGROUND is required')
local label = scheme:gsub('-', ' '):upper()

assert(background == 'dark' or background == 'light', 'unexpected background: ' .. background)

vim.opt.runtimepath:prepend(repo)
vim.o.shadafile = 'NONE'
vim.o.termguicolors = true
vim.o.background = background
vim.o.number = true
vim.o.relativenumber = false
vim.o.numberwidth = 3
vim.o.signcolumn = 'yes:1'
vim.o.cursorline = true
vim.o.cursorlineopt = 'both'
vim.o.wrap = false
vim.o.showmode = false
vim.o.showcmd = false
vim.o.ruler = false
vim.o.laststatus = 3
vim.o.cmdheight = 0
vim.o.scrolloff = 5
vim.o.sidescrolloff = 8
vim.o.title = true
vim.o.titlestring = label .. ' · ' .. background:upper() .. ' · Neovim'
vim.o.statusline = '  %t  %m%=' .. label .. ' · ' .. background:upper() .. '  %l:%c  '

require('token').setup({
  transparent = false,
  terminal_colors = true,
  plugins = {},
})
vim.cmd.colorscheme(scheme)

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(args)
    pcall(vim.treesitter.start, args.buf, 'lua')
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.defer_fn(function()
      vim.api.nvim_win_set_cursor(0, { 23, 8 })
    end, 100)
  end,
})
