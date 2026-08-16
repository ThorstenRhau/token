vim.opt.runtimepath:append(vim.fn.getcwd())

local token = require('token')

local function median(values)
  table.sort(values)
  return values[math.ceil(#values / 2)]
end

local function run(config, colorscheme)
  local samples = {}
  local count
  for _ = 1, 31 do
    token.setup(config)
    local started = vim.uv.hrtime()
    token.load(colorscheme)
    samples[#samples + 1] = (vim.uv.hrtime() - started) / 1e6
    count = vim.tbl_count(vim.api.nvim_get_hl(0, {}))
  end
  return median(samples), count
end

local results = {}
local appearances = require('token.appearance').all()
for _, appearance in ipairs(appearances) do
  local filtered_ms, filtered_groups = run({}, appearance.name)
  results[appearance.name] = {
    filtered_ms = filtered_ms,
    filtered_groups = filtered_groups,
  }
end
for _, appearance in ipairs(appearances) do
  local all_ms, all_groups = run({ plugins = { all = true } }, appearance.name)
  results[appearance.name] = vim.tbl_extend('force', results[appearance.name], {
    all_ms = all_ms,
    all_groups = all_groups,
  })
end

token.setup({})
require('token.compile').compile()

for _, appearance in ipairs(appearances) do
  local result = results[appearance.name]
  local label = appearance.name == 'token' and 'classic' or appearance.display_name:gsub('^Token ', '')
  print(string.format('%s filtered warm reload: %.3f ms, %d groups', label, result.filtered_ms, result.filtered_groups))
end
for _, appearance in ipairs(appearances) do
  local result = results[appearance.name]
  local label = appearance.name == 'token' and 'classic' or appearance.display_name:gsub('^Token ', '')
  print(string.format('%s all-plugin warm reload: %.3f ms, %d groups', label, result.all_ms, result.all_groups))
end
for _, appearance in ipairs(appearances) do
  local label = appearance.name == 'token' and 'classic' or appearance.display_name:gsub('^Token ', '')
  local dark_size = vim.uv.fs_stat(require('token.compile').path('dark', appearance.name)).size
  local light_size = vim.uv.fs_stat(require('token.compile').path('light', appearance.name)).size
  print(string.format('%s bytecode: dark %d bytes, light %d bytes', label, dark_size, light_size))
end
