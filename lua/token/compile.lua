local M = {}

local cache_format = 2
local cache_header = 'token-cache-v1\n'
local loaded_caches = {}
-- Caches from releases that keyed file names by a configuration hash.
local legacy_cache_name = '%-' .. string.rep('%x', 16) .. '%.lua$'

local function cache_stamp(stat)
  local mtime = stat.mtime or {}
  return table.concat({
    tostring(stat.ino),
    tostring(stat.size),
    tostring(mtime.sec),
    tostring(mtime.nsec),
  }, ':')
end

-- Error values may be tables, which tostring() renders as an address.
local function describe(err)
  if type(err) == 'table' then
    return type(err.message) == 'string' and err.message or vim.inspect(err)
  end
  return tostring(err)
end

local function discard(path)
  loaded_caches[path] = nil
  os.remove(path)
end

-- Caches are not tied to Token's source: users rerun :TokenCompile after
-- updating Token. Avoid vim.fn.sha256 on the load path; its first call costs
-- about 1.7 ms at startup.
local function stable(value)
  local kind = type(value)
  if kind == 'function' then
    local ok, dumped = pcall(string.dump, value)
    if not ok then
      error('token: callbacks must be dumpable Lua functions for compilation', 0)
    end
    return 'function:' .. dumped
  end
  if kind ~= 'table' then
    return kind .. ':' .. tostring(value)
  end
  local entries = {}
  for key, item in pairs(value) do
    entries[#entries + 1] = { stable(key), item }
  end
  table.sort(entries, function(a, b)
    return a[1] < b[1]
  end)
  local parts = {}
  for _, entry in ipairs(entries) do
    parts[#parts + 1] = entry[1] .. '=' .. stable(entry[2])
  end
  return '{' .. table.concat(parts, ',') .. '}'
end

---Return the deterministic serialization of the current configuration that a cache must match.
---@return string
function M.config_key()
  return stable(require('token.config').get())
end

---@param background 'dark'|'light'
---@param colorscheme? string
---@return string
function M.path(background, colorscheme)
  local appearance = require('token.appearance').get(colorscheme)
  return vim.fn.stdpath('cache') .. '/token/' .. appearance.cache_prefix .. background .. '.lua'
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
---@param config_key string
---@return string source
local function build_source(background, colorscheme, config_key)
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
    'config=' .. string.format('%q', config_key) .. ',',
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
  local config_key = M.config_key()

  local ok, err = pcall(function()
    for _, appearance in ipairs(appearances) do
      for _, bg in ipairs({ 'dark', 'light' }) do
        for key in pairs(package.loaded) do
          if key:match('^token%.') and key ~= 'token.compile' and key ~= 'token.config' then
            package.loaded[key] = nil
          end
        end
        local source = build_source(bg, appearance.name, config_key)
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

  local current = {}
  for _, pair in ipairs(pending) do
    assert(vim.uv.fs_rename(pair[1], pair[2]))
    loaded_caches[pair[2]] = nil
    current[pair[2]] = true
  end

  for _, name in ipairs(vim.fn.readdir(dir)) do
    local path = dir .. '/' .. name
    if not current[path] and name:match(legacy_cache_name) then
      discard(path)
    end
  end

  vim.notify(
    string.format('token: compiled %d appearances and %d variants', #appearances, #appearances * 2),
    vim.log.levels.INFO
  )
end

---Remove every compiled cache so later loads use the dynamic path.
---Leaves other files in the cache directory untouched.
function M.clear()
  local paths = {}
  for _, appearance in ipairs(require('token.appearance').all()) do
    for _, bg in ipairs({ 'dark', 'light' }) do
      paths[#paths + 1] = M.path(bg, appearance.name)
    end
  end
  local dir = vim.fn.stdpath('cache') .. '/token'
  if vim.fn.isdirectory(dir) == 1 then
    for _, name in ipairs(vim.fn.readdir(dir)) do
      if name:match(legacy_cache_name) or name:match('%.lua%.tmp$') then
        paths[#paths + 1] = dir .. '/' .. name
      end
    end
  end

  local removed = 0
  for _, path in ipairs(paths) do
    loaded_caches[path] = nil
    if os.remove(path) then
      removed = removed + 1
    end
  end
  vim.notify(string.format('token: removed %d compiled caches', removed), vim.log.levels.INFO)
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
  -- Non-dumpable callbacks cannot be compiled; use the dynamic path.
  local key_ok, config_key = pcall(M.config_key)
  if not key_ok then
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
    local reason
    if not ok then
      reason = describe(cache)
    elseif type(cache) ~= 'table' then
      reason = 'cache returned ' .. type(cache)
    elseif cache.format ~= cache_format then
      reason = 'cache format ' .. tostring(cache.format) .. ', expected ' .. cache_format
    elseif type(cache.config) ~= 'string' or type(cache.apply) ~= 'function' then
      reason = 'cache is missing its configuration key or apply function'
    end
    if reason then
      discard(path)
      vim.notify('token: compiled theme error, using dynamic path: ' .. reason, vim.log.levels.WARN)
      return false
    end
    loaded_caches[path] = { stamp = stamp, cache = cache }
  end

  -- Keep the file: another Neovim instance sharing the cache directory may
  -- use the configuration it was compiled for.
  if cache.config ~= config_key then
    return false
  end

  local applied, exec_err = pcall(cache.apply)
  if not applied then
    discard(path)
    vim.notify('token: compiled theme error, using dynamic path: ' .. describe(exec_err), vim.log.levels.WARN)
    return false
  end
  return true
end

return M
