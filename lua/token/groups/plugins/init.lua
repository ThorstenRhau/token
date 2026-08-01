local registry = {
  blink = 'token.groups.plugins.blink',
  blink_indent = 'token.groups.plugins.blink_indent',
  claudecode = 'token.groups.plugins.claudecode',
  cmp = 'token.groups.plugins.cmp',
  dap_ui = 'token.groups.plugins.dap_ui',
  diffview = 'token.groups.plugins.diffview',
  flash = 'token.groups.plugins.flash',
  fugitive = 'token.groups.plugins.fugitive',
  fzf = 'token.groups.plugins.fzf',
  gitsigns = 'token.groups.plugins.gitsigns',
  hlchunk = 'token.groups.plugins.hlchunk',
  ibl = 'token.groups.plugins.ibl',
  lazy = 'token.groups.plugins.lazy',
  markview = 'token.groups.plugins.markview',
  mason = 'token.groups.plugins.mason',
  matchup = 'token.groups.plugins.matchup',
  mini = 'token.groups.plugins.mini',
  neo_tree = 'token.groups.plugins.neo_tree',
  neogit = 'token.groups.plugins.neogit',
  noice = 'token.groups.plugins.noice',
  nvimtree = 'token.groups.plugins.nvimtree',
  oil = 'token.groups.plugins.oil',
  render_markdown = 'token.groups.plugins.render_markdown',
  snacks = 'token.groups.plugins.snacks',
  telescope = 'token.groups.plugins.telescope',
  todo_comments = 'token.groups.plugins.todo_comments',
  treesitter_context = 'token.groups.plugins.treesitter_context',
  trouble = 'token.groups.plugins.trouble',
  whichkey = 'token.groups.plugins.whichkey',
}

local M = {}
M.registry = registry

---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
function M.load(p, plugins)
  local groups = {}
  local names = vim.tbl_keys(registry)
  table.sort(names)
  for _, name in ipairs(names) do
    local enabled = plugins[name]
    if enabled == nil then
      enabled = plugins.all
    end
    if enabled then
      groups = vim.tbl_extend('force', groups, require(registry[name])(p))
    end
  end
  return groups
end

return M
