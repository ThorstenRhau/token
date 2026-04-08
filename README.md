# token

Token is a warm, muted Neovim 0.12+ colorscheme. Dark and light variants, no
configuration. There is no setup function. Load it and it works. The idea is
simple: a theme you never configure is a theme you stop thinking about.

Terminal themes for Ghostty, fish, delta, tmux and others are generated from the
same palette file, so everything matches without extra work.

## Showcase

| Dark | Light |
| --- | --- |
| ![Dark variant](https://rhau.se/token-dark.jpg) | ![Light variant](https://rhau.se/token-light.jpg) |

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

Respects `vim.o.background`. Set `dark` or `light` before loading the
colorscheme, or change it at runtime to switch variants.

## Structure

```
token/
├── colors/
│   └── token.lua
├── lua/
│   ├── lualine/themes/
│   │   └── token.lua
│   └── token/
│       ├── init.lua
│       ├── palette.lua
│       ├── terminal.lua
│       └── groups/
│           ├── base.lua
│           ├── treesitter.lua
│           ├── lsp.lua
│           └── plugins.lua
├── scripts/
│   └── gen_contrib.lua
├── README.md
└── LICENSE
```

## Supported plugins

blink.cmp, claudecode.nvim, diffview.nvim, fzf-lua, gitsigns.nvim,
hlchunk.nvim, indent-blankline.nvim, lualine.nvim, markview.nvim, mason.nvim,
mini.clue, mini.icons, mini.statusline, neogit, nvim-tree.lua, oil.nvim,
snacks.nvim, treesitter-context, trouble.nvim, vim-matchup.

## Contrib themes

Pre-generated theme files for terminal tools. Auto-generated from the palette;
rebuild after palette changes with `make contrib`.

| Tool                                                | Files                                          | Usage                                                                                                      |
| --------------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [bat](https://github.com/sharkdp/bat)               | `contrib/bat/token-{dark,light}.tmTheme`       | Copy to bat themes dir, run `bat cache --build`                                                            |
| [delta](https://github.com/dandavison/delta)        | `contrib/delta/token.gitconfig`                | Add `[include] path = /path/to/token.gitconfig`, then set `[delta] features = token-dark` or `token-light` |
| [fish](https://fishshell.com/)                      | `contrib/fish/token.theme`                     | Copy to `~/.config/fish/themes/`, then run `fish_config theme choose token`                                |
| [fzf](https://github.com/junegunn/fzf)              | `contrib/fzf/token-{dark,light}.fish`          | `source /path/to/token-dark.fish` in `config.fish` to append theme colors to `FZF_DEFAULT_OPTS`            |
| [ghostty](https://ghostty.org/)                     | `contrib/ghostty/token-{dark,light}`           | Copy to `~/.config/ghostty/themes/`, then set `theme = dark:token-dark,light:token-light`                  |
| [lazygit](https://github.com/jesseduffield/lazygit) | `contrib/lazygit/token-{dark,light}.yml`       | Merge into `~/.config/lazygit/config.yml`                                                                  |
| [ripgrep](https://github.com/BurntSushi/ripgrep)    | `contrib/ripgrep/token-{dark,light}.ripgreprc` | `RIPGREP_CONFIG_PATH=/path/to/token-dark.ripgreprc`                                                        |
| [starship](https://starship.rs/)                    | `contrib/starship/token-{dark,light}.toml`     | Append to `starship.toml`, set `palette = "token"`                                                         |
| [tmux](https://github.com/tmux/tmux)                | `contrib/tmux/token-{dark,light}.conf`         | `source-file /path/to/token-dark.conf` in tmux.conf                                                        |

## License

BSD 3-Clause
