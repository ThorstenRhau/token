# token — Emacs themes

Dark and light Emacs themes derived from the [token](https://github.com/ThorstenRhau/token)
colorscheme. Covers ~500 faces across syntax, org-mode, magit, completion
frameworks, diagnostics, diffs, shell, mail, and more. The emacs theme files were largely borrowed 
from the [themes](https://protesilaos.com/emacs/modus-themes) by Protesilaos.  

## Files

| File | Theme name |
| --- | --- |
| `token-dark-theme.el` | `token-dark` |
| `token-light-theme.el` | `token-light` |

## Requirements

Emacs 27+ (uses `:extend` and `(:style wave)` underlines).

## Installation

### Manual

1. Copy the `.el` files to a directory on your `custom-theme-load-path`:

```
cp token-dark.el token-light.el ~/.emacs.d/themes/ (or the location of your
theme files)  
```

2. Add the directory to your init file and load the theme:

```elisp
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'token-dark t)   ; or token-light
```

### straight.el

```elisp
(straight-use-package
 '(token-emacs :type git
               :host github
               :repo "ThorstenRhau/token"
               :files ("contrib/emacs/*.el")))

(add-to-list 'custom-theme-load-path
             (expand-file-name "straight/build/token-emacs"
                               straight-base-dir))
(load-theme 'token-dark t)
```

### use-package + straight.el

```elisp
(use-package token-emacs
  :straight (:host github :repo "ThorstenRhau/token"
             :files ("contrib/emacs/*.el"))
  :init
  (add-to-list 'custom-theme-load-path
               (expand-file-name "straight/build/token-emacs"
                                 straight-base-dir))
  :config
  (load-theme 'token-dark t))
```

## Switching between dark and light

```elisp
;; Load dark
(load-theme 'token-dark t)

;; Switch to light
(disable-theme 'token-dark)
(load-theme 'token-light t)
```

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
