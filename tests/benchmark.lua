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

local classic_filtered_ms, classic_filtered_groups = run({}, 'token')
local flint_filtered_ms, flint_filtered_groups = run({}, 'token-flint')
local classic_all_ms, classic_all_groups = run({ plugins = { all = true } }, 'token')
local flint_all_ms, flint_all_groups = run({ plugins = { all = true } }, 'token-flint')

token.setup({})
require('token.compile').compile()
local dark_size = vim.uv.fs_stat(require('token.compile').path('dark')).size
local light_size = vim.uv.fs_stat(require('token.compile').path('light')).size
local flint_dark_size = vim.uv.fs_stat(require('token.compile').path('dark', 'token-flint')).size
local flint_light_size = vim.uv.fs_stat(require('token.compile').path('light', 'token-flint')).size

print(string.format('classic filtered warm reload: %.3f ms, %d groups', classic_filtered_ms, classic_filtered_groups))
print(string.format('Flint filtered warm reload: %.3f ms, %d groups', flint_filtered_ms, flint_filtered_groups))
print(string.format('classic all-plugin warm reload: %.3f ms, %d groups', classic_all_ms, classic_all_groups))
print(string.format('Flint all-plugin warm reload: %.3f ms, %d groups', flint_all_ms, flint_all_groups))
print(string.format('classic bytecode: dark %d bytes, light %d bytes', dark_size, light_size))
print(string.format('Flint bytecode: dark %d bytes, light %d bytes', flint_dark_size, flint_light_size))
