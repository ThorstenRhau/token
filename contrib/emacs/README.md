# token - Emacs themes

Dark and light Emacs themes for classic Token, Token Flint, Token Temper, Token
Ultra, and Token Meridian, derived from the
[token](https://github.com/ThorstenRhau/token) Neovim colorscheme. Each covers
about 860 faces across syntax, org-mode, magit, completion frameworks,
diagnostics, diffs, shell, mail, and more.

> The `.el` files in this directory are generated from Token's appearance
> palettes via `scripts/gen_contrib.lua`. Do not edit them by hand; run
> `make contrib` after changing a palette and commit the regenerated output.

## Files

| File | Theme name |
| --- | --- |
| `token-dark-theme.el` | `token-dark` |
| `token-light-theme.el` | `token-light` |
| `token-flint-dark-theme.el` | `token-flint-dark` |
| `token-flint-light-theme.el` | `token-flint-light` |
| `token-temper-dark-theme.el` | `token-temper-dark` |
| `token-temper-light-theme.el` | `token-temper-light` |
| `token-ultra-dark-theme.el` | `token-ultra-dark` |
| `token-ultra-light-theme.el` | `token-ultra-light` |
| `token-meridian-dark-theme.el` | `token-meridian-dark` |
| `token-meridian-light-theme.el` | `token-meridian-light` |

## Requirements

Emacs 27+ (uses `:extend`, `(:style wave)` underlines, and `lexical-binding`).

## Installation

### Manual

1. Copy the `.el` files to a directory on your `custom-theme-load-path`:

```bash
cp token{,-flint,-temper,-ultra,-meridian}-{dark,light}-theme.el ~/.emacs.d/themes/
```

2. Add the directory to your init file and load the theme:

```elisp
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'token-dark t)          ; classic
(load-theme 'token-flint-dark t)    ; Flint
(load-theme 'token-temper-dark t)   ; Temper
(load-theme 'token-ultra-dark t)    ; Ultra
(load-theme 'token-meridian-dark t) ; Meridian
```

The files include a `;;;###autoload` cookie, so `package.el`-style installers
pick up the `custom-theme-load-path` entry automatically.

### straight.el

```elisp
(straight-use-package
 '(token-emacs :type git
               :host github
               :repo "ThorstenRhau/token"
               :files ("contrib/emacs/*.el")))

(load-theme 'token-dark t)
```

### use-package + straight.el

```elisp
(use-package token-emacs
  :straight (:host github :repo "ThorstenRhau/token"
             :files ("contrib/emacs/*.el"))
  :config
  (load-theme 'token-dark t))
```

## Switching between dark and light

Use the matching pair for the appearance you want. For example, classic Token:

```elisp
;; Load dark
(load-theme 'token-dark t)

;; Switch to light
(disable-theme 'token-dark)
(load-theme 'token-light t)
```

For Flint, Temper, Ultra, or Meridian, use the matching `token-flint-*`,
`token-temper-*`, `token-ultra-*`, or `token-meridian-*` pair.

To follow the system appearance automatically (macOS / Emacs 29+):

```elisp
(defun my/apply-token-theme (appearance)
  (pcase appearance
    ('dark  (load-theme 'token-dark  t))
    ('light (load-theme 'token-light t))))

(add-hook 'ns-system-appearance-change-functions #'my/apply-token-theme)
```

## Face coverage

| Category | Details |
| --- | --- |
| Core | `default`, cursor, fringe, region, line numbers, mode line, tab bar, whitespace |
| Syntax | All `font-lock-*` faces including Emacs 29+ additions |
| Search | `isearch`, `lazy-highlight`, occur, grep, compilation |
| Parens | `show-paren-*`, `rainbow-delimiters` (9 levels) |
| Outline | `outline-1` through `outline-8` |
| Diffs | `diff-mode`, `diff-hl`, `git-gutter`, ediff, smerge |
| Diagnostics | `flymake`, `flycheck` (including fringe and error list) |
| LSP | `eglot`, `lsp-mode`, `lsp-ui` |
| Completion | `corfu`, `company`, `vertico`, `ivy`, `consult`, `embark`, `orderless`, `marginalia` |
| Org | Headings 1–8, blocks, agenda, roam, tables, checkboxes, timestamps, priorities |
| Markdown | All heading levels, code, tables, links, footnotes, HTML |
| Version control | `magit` (full), `forge`, `git-commit`, `git-rebase`, `git-timemachine` |
| Navigation | `dired`, `diredfl`, `ibuffer`, `treemacs`, `neotree`, `xref` |
| Info / Help | `info`, `helpful`, `eldoc` |
| Shell | `eshell`, `comint`, `vterm`, `ansi-color` (all 16 colors) |
| Mail | `message`, `gnus`, `notmuch` |
| Feeds | `elfeed` |
| Web | `eww`, `shr` |
| UI tools | `transient`, `which-key`, `hydra`, `avy`, `pulsar` |
| REPL | `cider`, `slime`, `sly` |
| Emacs builtins | `calendar`, `package`, `customize`, `widget` |

## Credits

The initial face list was contributed by [@srg-dev](https://github.com/srg-dev)
in [#1](https://github.com/ThorstenRhau/token/pull/1), itself adapted from
Protesilaos' [Modus themes](https://protesilaos.com/emacs/modus-themes). This
directory turns that work into a palette-driven generator so the Emacs themes
stay in lockstep with the Neovim colorscheme across future palette changes.
