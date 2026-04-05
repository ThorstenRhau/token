local M = {}

function M.load()
  vim.cmd('hi clear')
  vim.g.colors_name = 'token'

  -- Clear cached modules so palette/groups pick up the new background
  for key in pairs(package.loaded) do
    if key:match('^token%.') then
      package.loaded[key] = nil
    end
  end

  local palette = require('token.palette')
  local p = palette(vim.o.background)

  local groups = vim.tbl_extend(
    'force',
    require('token.groups.base')(p),
    require('token.groups.treesitter')(p),
    require('token.groups.lsp')(p),
    require('token.groups.plugins')(p)
  )

  for group, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  local is_dark = vim.o.background == 'dark'
  require('token.terminal')(p, is_dark)
end

return M
