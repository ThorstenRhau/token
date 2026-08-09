vim.opt.runtimepath:append(vim.fn.getcwd())

local token = require('token')

local function median(values)
  table.sort(values)
  return values[math.ceil(#values / 2)]
end

local function run(config)
  local samples = {}
  local count
  for _ = 1, 31 do
    token.setup(config)
    local started = vim.uv.hrtime()
    token.load()
    samples[#samples + 1] = (vim.uv.hrtime() - started) / 1e6
    count = vim.tbl_count(vim.api.nvim_get_hl(0, {}))
  end
  return median(samples), count
end

local filtered_ms, filtered_groups = run({})
local all_ms, all_groups = run({ plugins = { all = true } })

token.setup({})
require('token.compile').compile()
local dark_size = vim.uv.fs_stat(require('token.compile').path('dark')).size
local light_size = vim.uv.fs_stat(require('token.compile').path('light')).size

print(string.format('filtered warm reload: %.3f ms, %d groups', filtered_ms, filtered_groups))
print(string.format('all-plugin warm reload: %.3f ms, %d groups', all_ms, all_groups))
print(string.format('bytecode: dark %d bytes, light %d bytes', dark_size, light_size))
