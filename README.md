# token

Token is a warm, muted Neovim 0.12+ colorscheme that is written in Lua. Dark and light variants, no
configuration. There is no setup function. Load it and it works. The idea is
simple: a theme you never configure is a theme you stop thinking about.

Terminal themes for Ghostty, fish, delta, tmux and others are generated from the
same palette file, so everything matches without extra work.

## Features

- Dark and light variants, switching at runtime via `vim.o.background`
- Treesitter capture groups for accurate syntax highlighting
- LSP semantic token highlights
- LSP diagnostic signs, virtual text, and underlines
- Diff highlights for buffers and signs
- Legacy syntax group coverage for non-Treesitter filetypes
- Terminal color support (ANSI colors 0–15)
- Lualine theme included
- Contrib themes for terminal tools generated from the same palette

## Showcase

| Dark                                            | Light                                            |
| ----------------------------------------------- | ------------------------------------------------ |
| ![Dark variant 1](https://rhau.se/token-d1.png) | ![Light variant 1](https://rhau.se/token-l1.png) |
| ![Dark variant 2](https://rhau.se/token-d2.png) | ![Light variant 2](https://rhau.se/token-l2.png) |

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

## Compilation

Token works out of the box without compilation. For faster startup, you can
pre-compile the theme into bytecode:

```vim
:TokenCompile
```

This writes compiled dark and light variants to `stdpath('cache')/token/`. On
next load the cached bytecode is used instead of the dynamic highlight path.

Rerun `:TokenCompile` after updating the plugin. If the cache becomes stale or
corrupt it is deleted automatically and the dynamic path is used as fallback.

## Supported plugins

- blink.cmp
- claudecode.nvim
- diffview.nvim
- flash.nvim
- fugitive.vim
- fzf-lua
- gitsigns.nvim
- hlchunk.nvim
- indent-blankline.nvim
- lazy.nvim
- lualine.nvim
- markview.nvim
- mason.nvim
- mini.clue
- mini.icons
- mini.statusline
- mini.surround
- neo-tree.nvim
- neogit
- noice.nvim
- nvim-cmp
- nvim-dap-ui
- nvim-tree.lua
- oil.nvim
- render-markdown.nvim
- snacks.nvim
- telescope.nvim
- todo-comments.nvim
- treesitter-context
- trouble.nvim
- vim-matchup
- which-key.nvim

## Contrib themes

Pre-generated theme files for terminal tools. Auto-generated from the palette;
rebuild after palette changes with `make contrib`.

| Tool                                                | Files                                          | Usage                                                                                           |
| --------------------------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| [bat](https://github.com/sharkdp/bat)               | `contrib/bat/token-{dark,light}.tmTheme`       | Copy to bat themes dir, run `bat cache --build`                                                 |
| [delta](https://github.com/dandavison/delta)        | `contrib/delta/token.gitconfig`                | Include from `~/.gitconfig`, set `features = token-dark` in `[delta]`                           |
| [emacs](https://www.gnu.org/software/emacs/)        | `contrib/emacs/token-{dark,light}-theme.el`    | Copy to `~/.emacs.d/themes/`, then `(load-theme 'token-dark t)`                                 |
| [fish](https://fishshell.com/)                      | `contrib/fish/token.theme`                     | Copy to `~/.config/fish/themes/`, then run `fish_config theme choose token`                     |
| [fzf](https://github.com/junegunn/fzf)              | `contrib/fzf/token-{dark,light}.fish`          | `source /path/to/token-dark.fish` in `config.fish` to append theme colors to `FZF_DEFAULT_OPTS` |
| [ghostty](https://ghostty.org/)                     | `contrib/ghostty/token-{dark,light}`           | Copy to `~/.config/ghostty/themes/`, then set `theme = dark:token-dark,light:token-light`       |
| [lazygit](https://github.com/jesseduffield/lazygit) | `contrib/lazygit/token-{dark,light}.yml`       | Merge into `~/.config/lazygit/config.yml`                                                       |
| [ripgrep](https://github.com/BurntSushi/ripgrep)    | `contrib/ripgrep/token-{dark,light}.ripgreprc` | `RIPGREP_CONFIG_PATH=/path/to/token-dark.ripgreprc`                                             |
| [starship](https://starship.rs/)                    | `contrib/starship/token-{dark,light}.toml`     | Append to `starship.toml`, set `palette = "token"`                                              |
| [tmux](https://github.com/tmux/tmux)                | `contrib/tmux/token-{dark,light}.conf`         | `source-file /path/to/token-dark.conf` in tmux.conf                                             |

## License

BSD 3-Clause
