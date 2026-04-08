---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function load(p)
  return vim.tbl_extend(
    'force',
    require('token.groups.editor')(p),
    require('token.groups.syntax')(p),
    require('token.groups.treesitter')(p),
    require('token.groups.lsp')(p),
    require('token.groups.diagnostics')(p),
    require('token.groups.diff')(p),
    require('token.groups.plugins').load(p)
  )
end

return load
