local plugin_modules = {
  'token.groups.plugins.blink',
  'token.groups.plugins.blink_indent',
  'token.groups.plugins.claudecode',
  'token.groups.plugins.cmp',
  'token.groups.plugins.dap_ui',
  'token.groups.plugins.diffview',
  'token.groups.plugins.flash',
  'token.groups.plugins.fugitive',
  'token.groups.plugins.fzf',
  'token.groups.plugins.gitsigns',
  'token.groups.plugins.hlchunk',
  'token.groups.plugins.ibl',
  'token.groups.plugins.lazy',
  'token.groups.plugins.markview',
  'token.groups.plugins.mason',
  'token.groups.plugins.matchup',
  'token.groups.plugins.mini',
  'token.groups.plugins.neo_tree',
  'token.groups.plugins.neogit',
  'token.groups.plugins.noice',
  'token.groups.plugins.nvimtree',
  'token.groups.plugins.oil',
  'token.groups.plugins.render_markdown',
  'token.groups.plugins.snacks',
  'token.groups.plugins.telescope',
  'token.groups.plugins.todo_comments',
  'token.groups.plugins.treesitter_context',
  'token.groups.plugins.trouble',
  'token.groups.plugins.whichkey',
}

local M = {}

---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
function M.load(p)
  local groups = {}
  for _, mod in ipairs(plugin_modules) do
    groups = vim.tbl_extend('force', groups, require(mod)(p))
  end
  return groups
end

return M
