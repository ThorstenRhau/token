-- Shared helpers for contrib generators.

local M = {}

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeds(command)
  return os.execute(command) == 0
end

local function is_symlink(path)
  return command_succeeds('test -L ' .. shell_quote(path))
end

local function path_exists(path)
  return command_succeeds('test -e ' .. shell_quote(path))
end

function M.validate_output_path(path)
  if type(path) ~= 'string' or path == '' or path:sub(1, 1) == '/' or path:find('[%z\r\n]') then
    error('output path must be a safe relative path: ' .. tostring(path), 0)
  end
  if path:find('//', 1, true) or path:sub(-1) == '/' then
    error('output path must be normalized: ' .. path, 0)
  end

  local current = ''
  for component in path:gmatch('[^/]+') do
    if component == '.' or component == '..' then
      error('output path must stay within the repository: ' .. path, 0)
    end
    current = current == '' and component or current .. '/' .. component
    if is_symlink(current) then
      error('refusing symlinked output path: ' .. current, 0)
    end
  end
end

function M.strip(hex)
  return hex:gsub('^#', '')
end

local function hex_to_rgb(hex)
  local h = M.strip(hex)
  return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

function M.rgb_fmt(hex)
  local r, g, b = hex_to_rgb(hex)
  return string.format('0x%02x,0x%02x,0x%02x', r, g, b)
end

function M.sgr_rgb(hex)
  local r, g, b = hex_to_rgb(hex)
  return string.format('38;2;%d;%d;%d', r, g, b)
end

function M.sgr_bg_rgb(hex)
  local r, g, b = hex_to_rgb(hex)
  return string.format('48;2;%d;%d;%d', r, g, b)
end

function M.read_file(path)
  local f, open_error = io.open(path, 'rb')
  if not f then
    if path_exists(path) then
      error('failed to open ' .. path .. ': ' .. tostring(open_error), 0)
    end
    return nil
  end
  local content, read_error = f:read('*a')
  if content == nil then
    f:close()
    error('failed to read ' .. path .. ': ' .. tostring(read_error), 0)
  end
  local closed, close_error = f:close()
  if not closed then
    error('failed to close ' .. path .. ': ' .. tostring(close_error), 0)
  end
  return content
end

function M.mkdir_p(path)
  M.validate_output_path(path)
  if not command_succeeds('mkdir -p ' .. shell_quote(path)) then
    error('failed to create output directory: ' .. path, 0)
  end
end

local function temporary_sibling(path)
  local dir = path:match('(.+)/[^/]+$') or '.'
  local name = path:match('([^/]+)$')
  local template = dir .. '/.' .. name .. '.tmp.XXXXXX'
  local pipe, pipe_error = io.popen('mktemp ' .. shell_quote(template), 'r')
  if not pipe then
    error('failed to start mktemp for ' .. path .. ': ' .. tostring(pipe_error), 0)
  end
  local temporary = pipe:read('*l')
  local closed = pipe:close()
  if not closed or not temporary or temporary == '' then
    if temporary then
      os.remove(temporary)
    end
    error('failed to create a temporary output beside ' .. path, 0)
  end
  return temporary
end

local function write_atomic(path, content)
  local temporary = temporary_sibling(path)
  local f, open_error = io.open(temporary, 'wb')
  if not f then
    os.remove(temporary)
    error('failed to open temporary output for ' .. path .. ': ' .. tostring(open_error), 0)
  end

  local written, write_error = f:write(content)
  if not written then
    f:close()
    os.remove(temporary)
    error('failed to write temporary output for ' .. path .. ': ' .. tostring(write_error), 0)
  end
  local flushed, flush_error = f:flush()
  if not flushed then
    f:close()
    os.remove(temporary)
    error('failed to flush temporary output for ' .. path .. ': ' .. tostring(flush_error), 0)
  end
  local closed, close_error = f:close()
  if not closed then
    os.remove(temporary)
    error('failed to close temporary output for ' .. path .. ': ' .. tostring(close_error), 0)
  end
  if not command_succeeds('chmod 0644 ' .. shell_quote(temporary)) then
    os.remove(temporary)
    error('failed to set permissions on temporary output for ' .. path, 0)
  end

  local renamed, rename_error = os.rename(temporary, path)
  if not renamed then
    os.remove(temporary)
    error('failed to publish ' .. path .. ': ' .. tostring(rename_error), 0)
  end
end

function M.write_if_changed(path, content, verify)
  M.validate_output_path(path)
  local existing = M.read_file(path)
  if existing == content then
    if not verify then
      io.write('skip: ' .. path .. ' (unchanged)\n')
    end
    return true
  end
  if verify then
    if existing == nil then
      io.stderr:write('missing: ' .. path .. '\n')
    else
      io.stderr:write('outdated: ' .. path .. '\n')
    end
    return false
  end
  local dir = path:match('(.+)/[^/]+$')
  if dir then
    M.mkdir_p(dir)
  end
  write_atomic(path, content)
  io.write('wrote: ' .. path .. '\n')
  return true
end

function M.list_files(root)
  M.validate_output_path(root)
  local command = 'find ' .. shell_quote(root) .. ' \\( -type f -o -type l \\) -print'
  local pipe, pipe_error = io.popen(command, 'r')
  if not pipe then
    error('failed to inspect generated outputs: ' .. tostring(pipe_error), 0)
  end
  local paths = {}
  for path in pipe:lines() do
    paths[#paths + 1] = path
  end
  local closed = pipe:close()
  if not closed then
    error('failed to inspect generated outputs under ' .. root, 0)
  end
  table.sort(paths)
  return paths
end

function M.unexpected_paths(actual, expected, allowed)
  local known = {}
  for _, path in ipairs(expected) do
    known[path] = true
  end
  for _, path in ipairs(allowed or {}) do
    known[path] = true
  end

  local unexpected = {}
  for _, path in ipairs(actual) do
    if not known[path] then
      unexpected[#unexpected + 1] = path
    end
  end
  table.sort(unexpected)
  return unexpected
end

function M.extend_lines(dst, src)
  for _, line in ipairs(src) do
    dst[#dst + 1] = line
  end
end

return M
