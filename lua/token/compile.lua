local M = {}

---@param background 'dark'|'light'
---@return string
function M.path(background)
  return vim.fn.stdpath('cache') .. '/token/' .. background .. '.lua'
end

---@param t table<string, any>
---@return string
local function serialize_hl(t)
  local keys = vim.tbl_keys(t)
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do
    local v = t[k]
    local tv = type(v)
    if tv == 'string' then
      parts[#parts + 1] = k .. '=' .. string.format('%q', v)
    elseif tv == 'boolean' then
      parts[#parts + 1] = k .. '=' .. tostring(v)
    elseif tv == 'number' then
      parts[#parts + 1] = k .. '=' .. v
    end
  end
  return '{' .. table.concat(parts, ',') .. '}'
end

---@param background 'dark'|'light'
---@return string source
local function build_source(background)
  local is_dark = background == 'dark'
  local p = require('token.palette')(background)
  local groups = require('token.groups')(p)
  local terminal = require('token.terminal').colors(p, is_dark)

  local lines = {
    "vim.cmd('hi clear')",
    "vim.g.colors_name='token'",
    'local H=vim.api.nvim_set_hl',
  }

  local names = vim.tbl_keys(groups)
  table.sort(names)
  for _, name in ipairs(names) do
    lines[#lines + 1] = 'H(0,' .. string.format('%q', name) .. ',' .. serialize_hl(groups[name]) .. ')'
  end

  for i = 0, 15 do
    lines[#lines + 1] = 'vim.g.terminal_color_' .. i .. '=' .. string.format('%q', terminal[i])
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
        if key:match('^token%.') and key ~= 'token.compile' then
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
  local path = M.path(background)
  if not vim.uv.fs_stat(path) then
    return false
  end
  local chunk, err = loadfile(path)
  if not chunk then
    vim.notify('token: cache load failed, using dynamic path: ' .. err, vim.log.levels.WARN)
    os.remove(path)
    return false
  end
  local ok, exec_err = pcall(chunk)
  if not ok then
    vim.notify('token: compiled theme error, using dynamic path: ' .. exec_err, vim.log.levels.WARN)
    os.remove(path)
    return false
  end
  return true
end

return M
