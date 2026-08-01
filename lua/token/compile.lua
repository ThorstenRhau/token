local M = {}

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
---@return string
function M.path(background)
  return vim.fn.stdpath('cache') .. '/token/' .. background .. '-' .. M.fingerprint() .. '.lua'
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
---@return string source
local function build_source(background)
  local is_dark = background == 'dark'
  local p, groups = require('token.theme').build(background)

  local lines = {
    "vim.cmd('hi clear')",
    "vim.g.colors_name='token'",
    'local H=vim.api.nvim_set_hl',
  }

  local names = vim.tbl_keys(groups)
  table.sort(names)
  for _, name in ipairs(names) do
    lines[#lines + 1] = 'H(0,' .. string.format('%q', name) .. ',' .. serialize(groups[name]) .. ')'
  end

  if require('token.config').get().terminal_colors then
    local terminal = require('token.terminal').colors(p, is_dark)
    for i = 0, 15 do
      lines[#lines + 1] = 'vim.g.terminal_color_' .. i .. '=' .. string.format('%q', terminal[i])
    end
  end

  return table.concat(lines, '\n') .. '\n'
end

function M.compile()
  local dir = vim.fn.stdpath('cache') .. '/token'
  vim.fn.mkdir(dir, 'p')

  local pending = {}

  local ok, err = pcall(function()
    for _, bg in ipairs({ 'dark', 'light' }) do
      for key in pairs(package.loaded) do
        if key:match('^token%.') and key ~= 'token.compile' and key ~= 'token.config' then
          package.loaded[key] = nil
        end
      end
      local source = build_source(bg)
      local chunk = assert(load(source, '=' .. bg))
      local bytecode = string.dump(chunk)

      local final = M.path(bg)
      local tmp = final .. '.tmp'
      local f = assert(io.open(tmp, 'wb'))
      assert(f:write(bytecode))
      f:close()
      pending[#pending + 1] = { tmp, final }
    end
  end)

  if not ok then
    for _, pair in ipairs(pending) do
      os.remove(pair[1])
    end
    for _, bg in ipairs({ 'dark', 'light' }) do
      os.remove(M.path(bg))
    end
    error(err)
  end

  for _, pair in ipairs(pending) do
    assert(vim.uv.fs_rename(pair[1], pair[2]))
  end

  vim.notify('token: compiled dark and light variants', vim.log.levels.INFO)
end

---@param background 'dark'|'light'
---@return boolean
function M.load(background)
  local path_ok, path = pcall(M.path, background)
  if not path_ok then
    return false
  end
  if not vim.uv.fs_stat(path) then
    return false
  end
  local chunk, err = loadfile(path)
  if not chunk then
    os.remove(path)
    vim.notify('token: cache load failed, using dynamic path: ' .. tostring(err), vim.log.levels.WARN)
    return false
  end
  local ok, exec_err = pcall(chunk)
  if not ok then
    os.remove(path)
    vim.notify('token: compiled theme error, using dynamic path: ' .. tostring(exec_err), vim.log.levels.WARN)
    return false
  end
  return true
end

return M
