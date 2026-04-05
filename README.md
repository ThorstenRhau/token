# token

A Neovim colorscheme with dark and light variants. Requires Neovim 0.12+.

## Install

```lua
-- vim.pack (Neovim 0.12+)
vim.pack.add('https://github.com/ThorstenRhau/token')

-- lazy.nvim
{ 'ThorstenRhau/token' }
```

## Usage

```lua
vim.cmd.colorscheme('token')
```

Respects `vim.o.background`. Set `dark` or `light` before loading the colorscheme, or change it at runtime to switch variants.

## Structure

```
token/
├── colors/
│   └── token.lua
├── lua/
│   └── token/
│       ├── init.lua
│       ├── palette.lua
│       ├── terminal.lua
│       └── groups/
│           ├── base.lua
│           ├── treesitter.lua
│           ├── lsp.lua
│           └── plugins.lua
├── README.md
└── LICENSE
```

## Supported plugins

blink.cmp, claudecode.nvim, diffview.nvim, fzf-lua, gitsigns.nvim, indent-blankline.nvim, markview.nvim, mason.nvim, mini.clue, mini.icons, mini.statusline, neogit, nvim-tree.lua, oil.nvim, treesitter-context, trouble.nvim, vim-matchup.

## License

BSD 3-Clause
