local M = {}

local cache_format = 1
local cache_header = 'token-cache-v1\n'
local loaded_caches = {}

local function cache_stamp(stat)
  local mtime = stat.mtime or {}
  return table.concat({
    tostring(stat.ino),
    tostring(stat.size),
    tostring(mtime.sec),
    tostring(mtime.nsec),
  }, ':')
end

local function discard(path)
  loaded_caches[path] = nil
  os.remove(path)
end

local function source_root()
  local source = debug.getinfo(1, 'S').source
  local path = source:sub(1, 1) == '@' and source:sub(2) or source
  return vim.fn.fnamemodify(path, ':p:h:h:h')
end

local function git_identity(root)
  local head = io.open(root .. '/.git/HEAD', 'r')
  if not head then
    return nil
  end
  local value = head:read('*l')
  head:close()
  if value and #value == 40 and value:match('^[0-9a-fA-F]+$') then
    return 'git:' .. value:lower()
  end
end

local function metadata_identity(root)
  local base = root .. '/lua/token'
  local files = vim.fn.globpath(base, '**/*.lua', false, true)
  table.sort(files)

  local parts = {}
  for _, path in ipairs(files) do
    local stat = vim.uv.fs_stat(path)
    if stat then
      local mtime = stat.mtime
      parts[#parts + 1] = table.concat({
        path:sub(#base + 2),
        tostring(stat.size),
        tostring(mtime.sec),
        tostring(mtime.nsec),
      }, '\0')
    end
  end
  return 'tree:' .. vim.fn.sha256(table.concat(parts, '\n'))
end

---Return the identity of the Token source that generated a cache.
---@return string
function M.source_identity()
  local root = source_root()
  return git_identity(root) or metadata_identity(root)
end

local function stable(value)
  local kind = type(value)
  if kind == 'function' then
    local ok, dumped = pcall(string.dump, value)
    if not ok then
      error('token: callbacks must be dumpable Lua functions for compilation', 0)
    end
    return 'function:' .. vim.fn.sha256(dumped)
  end
  if kind ~= 'table' then
    return kind .. ':' .. tostring(value)
  end
  local keys = vim.tbl_keys(value)
  table.sort(keys, function(a, b)
    return stable(a) < stable(b)
  end)
  local parts = {}
  for _, key in ipairs(keys) do
    parts[#parts + 1] = stable(key) .. '=' .. stable(value[key])
  end
  return '{' .. table.concat(parts, ',') .. '}'
end

function M.fingerprint()
  return vim.fn.sha256(stable(require('token.config').get())):sub(1, 16)
end

---@param background 'dark'|'light'
---@param colorscheme? string
---@return string
function M.path(background, colorscheme)
  local appearance = require('token.appearance').get(colorscheme)
  return vim.fn.stdpath('cache')
    .. '/token/'
    .. appearance.cache_prefix
    .. background
    .. '-'
    .. M.fingerprint()
    .. '.lua'
end

local function serialize(value)
  local kind = type(value)
  if kind == 'string' then
    return string.format('%q', value)
  end
  if kind == 'boolean' or kind == 'number' then
    return tostring(value)
  end
  if kind ~= 'table' then
    error('token: compiled highlights do not support ' .. kind .. ' values', 0)
  end

  local keys = vim.tbl_keys(value)
  table.sort(keys, function(a, b)
    return stable(a) < stable(b)
  end)
  local parts = {}
  for _, k in ipairs(keys) do
    parts[#parts + 1] = '[' .. serialize(k) .. ']=' .. serialize(value[k])
  end
  return '{' .. table.concat(parts, ',') .. '}'
end

---@param background 'dark'|'light'
---@param colorscheme string
---@param identity string
---@return string source
local function build_source(background, colorscheme, identity)
  local is_dark = background == 'dark'
  local p, groups = require('token.theme').build(background, colorscheme)

  local lines = { 'local G={' }
  local names = vim.tbl_keys(groups)
  table.sort(names)
  for _, name in ipairs(names) do
    lines[#lines + 1] = '{' .. string.format('%q', name) .. ',' .. serialize(groups[name]) .. '},'
  end
  vim.list_extend(lines, {
    '}',
    'return {',
    'format=' .. cache_format .. ',',
    'source=' .. string.format('%q', identity) .. ',',
    'apply=function()',
    "vim.cmd('hi clear')",
    'vim.g.colors_name=' .. string.format('%q', colorscheme),
    'local H=vim.api.nvim_set_hl',
    'for i=1,#G do',
    'local g=G[i]',
    'H(0,g[1],g[2])',
    'end',
  })

  if require('token.config').get().terminal_colors then
    local terminal = require('token.terminal').colors(p, is_dark, colorscheme)
    for i = 0, 15 do
      lines[#lines + 1] = 'vim.g.terminal_color_' .. i .. '=' .. string.format('%q', terminal[i])
    end
  end

  lines[#lines + 1] = 'end,'
  lines[#lines + 1] = '}'
  return table.concat(lines, '\n') .. '\n'
end

function M.compile()
  local dir = vim.fn.stdpath('cache') .. '/token'
  vim.fn.mkdir(dir, 'p')

  local pending = {}
  local appearances = require('token.appearance').all()
  local identity = M.source_identity()

  local ok, err = pcall(function()
    for _, appearance in ipairs(appearances) do
      for _, bg in ipairs({ 'dark', 'light' }) do
        for key in pairs(package.loaded) do
          if key:match('^token%.') and key ~= 'token.compile' and key ~= 'token.config' then
            package.loaded[key] = nil
          end
        end
        local source = build_source(bg, appearance.name, identity)
        local chunk = assert(load(source, '=' .. appearance.name .. '-' .. bg))
        local bytecode = string.dump(chunk)

        local final = M.path(bg, appearance.name)
        local tmp = final .. '.tmp'
        local f = assert(io.open(tmp, 'wb'))
        assert(f:write(cache_header .. bytecode))
        f:close()
        pending[#pending + 1] = { tmp, final }
      end
    end
  end)

  if not ok then
    for _, pair in ipairs(pending) do
      os.remove(pair[1])
    end
    error(err)
  end

  for _, pair in ipairs(pending) do
    assert(vim.uv.fs_rename(pair[1], pair[2]))
    loaded_caches[pair[2]] = nil
  end

  vim.notify(
    string.format('token: compiled %d appearances and %d variants', #appearances, #appearances * 2),
    vim.log.levels.INFO
  )
end

---@param background 'dark'|'light'
---@param colorscheme? string
---@return boolean
function M.load(background, colorscheme)
  local path_ok, path = pcall(M.path, background, colorscheme)
  if not path_ok then
    return false
  end
  local stat = vim.uv.fs_stat(path)
  if not stat then
    loaded_caches[path] = nil
    return false
  end
  local stamp = cache_stamp(stat)
  local loaded = loaded_caches[path]
  local cache = loaded and loaded.stamp == stamp and loaded.cache or nil
  if not cache then
    local file, read_err = io.open(path, 'rb')
    if not file then
      discard(path)
      vim.notify('token: cache load failed, using dynamic path: ' .. tostring(read_err), vim.log.levels.WARN)
      return false
    end
    local content = file:read('*a')
    file:close()
    if content:sub(1, #cache_header) ~= cache_header then
      discard(path)
      vim.notify('token: cache load failed, using dynamic path: unrecognized cache format', vim.log.levels.WARN)
      return false
    end

    local chunk, err = load(content:sub(#cache_header + 1), '=' .. path)
    if not chunk then
      discard(path)
      vim.notify('token: cache load failed, using dynamic path: ' .. tostring(err), vim.log.levels.WARN)
      return false
    end

    local ok
    ok, cache = pcall(chunk)
    if
      not ok
      or type(cache) ~= 'table'
      or cache.format ~= cache_format
      or type(cache.source) ~= 'string'
      or type(cache.apply) ~= 'function'
    then
      discard(path)
      vim.notify('token: compiled theme error, using dynamic path: ' .. tostring(cache), vim.log.levels.WARN)
      return false
    end
    loaded_caches[path] = { stamp = stamp, cache = cache }
  end

  if cache.source ~= M.source_identity() then
    discard(path)
    return false
  end

  local applied, exec_err = pcall(cache.apply)
  if not applied then
    discard(path)
    vim.notify('token: compiled theme error, using dynamic path: ' .. tostring(exec_err), vim.log.levels.WARN)
    return false
  end
  return true
end

return M
