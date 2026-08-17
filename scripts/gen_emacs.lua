-- Emacs theme generator for token colorscheme.

local lib = require('gen_lib')
local extend_lines = lib.extend_lines

-- ---------------------------------------------------------------------------
-- Emacs (.el)
-- ---------------------------------------------------------------------------

-- Palette keys bound in the emacs `let` block. Grouped by semantic category
-- (bg ramp -> fg ramp -> accents -> syntax -> brights -> diffs -> ui).
-- Only keys referenced by EMACS_FACES are bound: the emacs byte-compiler warns
-- on unused lexical bindings, and `emacs_audit` enforces the invariant both
-- ways (unused key here, or missing key referenced from EMACS_FACES, both
-- error at generation time).
-- To add a new palette key: add it here AND reference it from EMACS_FACES.
local EMACS_LET_KEYS = {
  'bg0',
  'bg1',
  'bg2',
  'bg3',
  'bg4',
  'bg5',
  'fg0',
  'fg1',
  'fg2',
  'fg3',
  'accent',
  'accent2',
  'blue',
  'green',
  'red',
  'yellow',
  'purple',
  'cyan',
  'orange',
  'bright_green',
  'bright_blue',
  'bright_purple',
  'bright_cyan',
  'diff_add',
  'diff_del',
  'diff_add_inline',
  'diff_del_inline',
  'diff_change',
  'diff_text',
  'sel',
  'match',
}

-- Face table schema:
--   Face entry (positional [1] is the elisp face name, rest are attributes):
--     { 'face-name', fg = 'palette_key', bg = 'palette_key',
--       bold = true, italic = true, underline = true|false|<table>,
--       strike = true, extend = true, box = true|<table>, height = N }
--   Nested tables:
--     underline = { style = 'wave'|'dots', color = 'palette_key' }
--     box       = { line_width = N, color = 'palette_key' }
--   Section marker (emitted as a comment, not a face):
--     { section = 'Label' }
--   Literal escape hatch (faces with no palette refs, e.g. `bold`):
--     { 'face-name', literal = '(:weight bold)' }
local EMACS_FACES = {
  { section = 'Core' },
  { 'default', fg = 'fg0', bg = 'bg3' },
  { 'cursor', bg = 'fg0' },
  { 'fringe', fg = 'fg3', bg = 'bg3' },
  { 'region', bg = 'sel', extend = true },
  { 'secondary-selection', bg = 'bg5', extend = true },
  { 'highlight', bg = 'bg5' },
  { 'hl-line', bg = 'bg5', extend = true },
  { 'shadow', fg = 'fg2' },
  { 'vertical-border', fg = 'bg4' },
  { 'window-divider', fg = 'bg4' },
  { 'window-divider-first-pixel', fg = 'bg4' },
  { 'window-divider-last-pixel', fg = 'bg4' },
  { 'internal-border', bg = 'bg1' },
  { 'child-frame-border', bg = 'bg1' },
  { 'fill-column-indicator', fg = 'bg5' },
  { 'separator-line', fg = 'bg4' },
  { 'nobreak-space', fg = 'fg3', underline = true },
  { 'nobreak-hyphen', fg = 'fg3' },
  { 'homoglyph', fg = 'yellow' },
  { 'escape-glyph', fg = 'cyan' },
  { 'glyphless-char', fg = 'fg3' },
  { 'trailing-whitespace', bg = 'red' },
  { 'tooltip', fg = 'fg0', bg = 'bg0' },
  { 'menu', fg = 'fg0', bg = 'bg1' },
  { 'minibuffer-prompt', fg = 'blue', bold = true },
  { 'link', fg = 'blue', underline = true },
  { 'link-visited', fg = 'purple', underline = true },
  { 'button', fg = 'blue', underline = true },
  { 'bookmark-face', fg = 'accent', bg = 'bg4' },
  { 'bookmark-menu-bookmark', fg = 'accent', bold = true },

  { section = 'Text / Formatting' },
  { 'bold', literal = '(:weight bold)' },
  { 'italic', literal = '(:slant italic)' },
  { 'bold-italic', literal = '(:weight bold :slant italic)' },
  { 'underline', literal = '(:underline t)' },
  { 'fixed-pitch', literal = '(:family "monospace")' },
  { 'variable-pitch', literal = '(:family "sans-serif")' },

  { section = 'Line numbers' },
  { 'line-number', fg = 'fg3', bg = 'bg3' },
  { 'line-number-current-line', fg = 'accent2', bg = 'bg3', bold = true },
  { 'line-number-major-tick', fg = 'fg2', bg = 'bg3', bold = true },
  { 'line-number-minor-tick', fg = 'fg3', bg = 'bg3' },

  { section = 'Mode line' },
  { 'mode-line', fg = 'fg1', bg = 'bg1' },
  { 'mode-line-inactive', fg = 'fg3', bg = 'bg1' },
  { 'mode-line-buffer-id', fg = 'accent', bold = true },
  { 'mode-line-highlight', fg = 'accent' },
  { 'mode-line-emphasis', bold = true },
  { 'header-line', fg = 'fg1', bg = 'bg1' },
  { 'header-line-highlight', fg = 'accent', bold = true },
  { 'doom-modeline-buffer-path', fg = 'fg2' },
  { 'doom-modeline-buffer-file', fg = 'fg0', bold = true },
  { 'doom-modeline-buffer-modified', fg = 'accent' },
  { 'doom-modeline-project-dir', fg = 'blue' },
  { 'doom-modeline-error', fg = 'red', bold = true },
  { 'doom-modeline-warning', fg = 'yellow', bold = true },
  { 'doom-modeline-info', fg = 'green', bold = true },

  { section = 'Tab bar / Tab line' },
  { 'tab-bar', fg = 'fg2', bg = 'bg1' },
  { 'tab-bar-tab', fg = 'fg0', bg = 'bg3', bold = true },
  { 'tab-bar-tab-inactive', fg = 'fg2', bg = 'bg1' },
  { 'tab-bar-tab-group-current', fg = 'accent', bg = 'bg3', bold = true },
  { 'tab-bar-tab-group-inactive', fg = 'fg2', bg = 'bg1' },
  { 'tab-bar-tab-ungrouped', fg = 'fg3', bg = 'bg1' },
  { 'tab-line', fg = 'fg2', bg = 'bg1' },
  { 'tab-line-tab', fg = 'fg1', bg = 'bg3' },
  { 'tab-line-tab-current', fg = 'fg0', bg = 'bg3', bold = true },
  { 'tab-line-tab-inactive', fg = 'fg2', bg = 'bg1' },
  { 'tab-line-tab-modified', fg = 'accent' },
  { 'tab-line-highlight', fg = 'fg0', bg = 'bg5' },
  { 'tab-line-close-highlight', fg = 'red' },
  { 'tab-line-new-tab', fg = 'green' },

  { section = 'Whitespace' },
  { 'whitespace-space', fg = 'bg5' },
  { 'whitespace-hspace', fg = 'bg5' },
  { 'whitespace-tab', fg = 'bg5' },
  { 'whitespace-newline', fg = 'bg5' },
  { 'whitespace-missing-newline-at-eof', fg = 'red' },
  { 'whitespace-trailing', fg = 'red', bg = 'diff_del' },
  { 'whitespace-line', bg = 'diff_del' },
  { 'whitespace-space-before-tab', bg = 'diff_del' },
  { 'whitespace-indentation', fg = 'fg3' },
  { 'whitespace-big-indent', bg = 'diff_del' },
  { 'whitespace-empty', bg = 'diff_change' },
  { 'whitespace-space-after-tab', bg = 'diff_del' },

  { section = 'Font lock' },
  { 'font-lock-comment-face', fg = 'fg2', italic = true },
  { 'font-lock-comment-delimiter-face', fg = 'fg2', italic = true },
  { 'font-lock-doc-face', fg = 'fg2', italic = true },
  { 'font-lock-doc-markup-face', fg = 'green', italic = true },
  { 'font-lock-string-face', fg = 'green' },
  { 'font-lock-keyword-face', fg = 'accent2' },
  { 'font-lock-builtin-face', fg = 'purple' },
  { 'font-lock-function-name-face', fg = 'accent' },
  { 'font-lock-function-call-face', fg = 'accent' },
  { 'font-lock-variable-name-face', fg = 'fg0' },
  { 'font-lock-variable-use-face', fg = 'fg0' },
  { 'font-lock-type-face', fg = 'blue' },
  { 'font-lock-constant-face', fg = 'purple' },
  { 'font-lock-preprocessor-face', fg = 'purple' },
  { 'font-lock-negation-char-face', fg = 'red' },
  { 'font-lock-warning-face', fg = 'yellow' },
  { 'font-lock-regexp-grouping-backslash', fg = 'purple' },
  { 'font-lock-regexp-grouping-construct', fg = 'purple' },
  { 'font-lock-escape-face', fg = 'purple' },
  { 'font-lock-number-face', fg = 'orange' },
  { 'font-lock-operator-face', fg = 'fg1' },
  { 'font-lock-delimiter-face', fg = 'fg1' },
  { 'font-lock-bracket-face', fg = 'fg1' },
  { 'font-lock-punctuation-face', fg = 'fg1' },
  { 'font-lock-misc-punctuation-face', fg = 'fg1' },
  { 'font-lock-property-name-face', fg = 'fg0' },
  { 'font-lock-property-use-face', fg = 'fg0' },
  { 'font-lock-reference-face', fg = 'blue' },

  { section = 'Treesitter (Emacs 29+)' },
  { 'treesit-fold-replacement-face', fg = 'fg2', bg = 'bg4' },

  { section = 'Search' },
  { 'isearch', fg = 'fg0', bg = 'match', bold = true },
  { 'isearch-fail', fg = 'fg0', bg = 'diff_del' },
  { 'isearch-group-1', fg = 'bg3', bg = 'accent' },
  { 'isearch-group-2', fg = 'bg3', bg = 'accent2' },
  { 'lazy-highlight', bg = 'bg5' },
  { 'match', fg = 'fg0', bg = 'match' },
  { 'query-replace', fg = 'fg0', bg = 'diff_del' },

  { section = 'Occur / grep / compilation' },
  { 'occur-match', fg = 'fg0', bg = 'match', bold = true },
  { 'occur-prefix', fg = 'fg2' },
  { 'occur-suffix', fg = 'fg2' },
  { 'grep-match-face', fg = 'fg0', bg = 'match', bold = true },
  { 'grep-hit-face', fg = 'accent', bold = true },
  { 'grep-context-face', fg = 'fg2' },
  { 'compilation-error', fg = 'red', bold = true },
  { 'compilation-warning', fg = 'yellow' },
  { 'compilation-info', fg = 'blue' },
  { 'compilation-mode-line-exit', fg = 'green', bold = true },
  { 'compilation-mode-line-fail', fg = 'red', bold = true },
  { 'compilation-mode-line-run', fg = 'yellow', bold = true },
  { 'compilation-line-number', fg = 'accent' },
  { 'compilation-column-number', fg = 'fg2' },
  { 'compilation-face', fg = 'fg0' },
  { 'next-error', bg = 'diff_change', extend = true },

  { section = 'Parentheses / Delimiters' },
  { 'show-paren-match', fg = 'accent', bold = true, underline = true },
  { 'show-paren-mismatch', fg = 'fg0', bg = 'red' },
  { 'show-paren-match-expression', bg = 'bg5' },
  { 'rainbow-delimiters-depth-1-face', fg = 'fg1' },
  { 'rainbow-delimiters-depth-2-face', fg = 'cyan' },
  { 'rainbow-delimiters-depth-3-face', fg = 'blue' },
  { 'rainbow-delimiters-depth-4-face', fg = 'purple' },
  { 'rainbow-delimiters-depth-5-face', fg = 'accent' },
  { 'rainbow-delimiters-depth-6-face', fg = 'green' },
  { 'rainbow-delimiters-depth-7-face', fg = 'accent2' },
  { 'rainbow-delimiters-depth-8-face', fg = 'bright_cyan' },
  { 'rainbow-delimiters-depth-9-face', fg = 'bright_blue' },
  { 'rainbow-delimiters-base-error-face', fg = 'red' },
  { 'rainbow-delimiters-mismatched-face', fg = 'fg0', bg = 'red' },
  { 'rainbow-delimiters-unmatched-face', fg = 'fg0', bg = 'red' },
  { 'paren-face', fg = 'fg3' },

  { section = 'Outline' },
  { 'outline-1', fg = 'accent', bold = true },
  { 'outline-2', fg = 'accent2', bold = true },
  { 'outline-3', fg = 'blue', bold = true },
  { 'outline-4', fg = 'green', bold = true },
  { 'outline-5', fg = 'cyan', bold = true },
  { 'outline-6', fg = 'purple', bold = true },
  { 'outline-7', fg = 'yellow', bold = true },
  { 'outline-8', fg = 'red', bold = true },
  { 'outline-minor-0', bg = 'bg4' },
  { 'outline-minor-1', fg = 'accent', bold = true },

  { section = 'Diffs' },
  { 'diff-header', fg = 'fg0', bg = 'bg2', bold = true, extend = true },
  { 'diff-file-header', fg = 'accent', bg = 'bg2', bold = true, extend = true },
  { 'diff-index', fg = 'fg2', bg = 'bg2', extend = true },
  { 'diff-function', fg = 'cyan', bg = 'diff_change', extend = true },
  { 'diff-hunk-header', fg = 'cyan', bg = 'diff_change', extend = true },
  { 'diff-added', fg = 'bright_green', bg = 'diff_add', extend = true },
  { 'diff-removed', fg = 'red', bg = 'diff_del', extend = true },
  { 'diff-changed', fg = 'yellow', bg = 'diff_change', extend = true },
  { 'diff-unchanged', fg = 'fg2', extend = true },
  { 'diff-context', fg = 'fg2', extend = true },
  { 'diff-indicator-added', fg = 'green', bg = 'diff_add' },
  { 'diff-indicator-removed', fg = 'red', bg = 'diff_del' },
  { 'diff-indicator-changed', fg = 'yellow', bg = 'diff_change' },
  { 'diff-refine-added', bg = 'diff_add_inline', extend = true },
  { 'diff-refine-removed', bg = 'diff_del_inline', extend = true },
  { 'diff-refine-changed', bg = 'diff_text', extend = true },
  { 'diff-nonexistent', fg = 'fg3' },
  { 'diff-error', fg = 'red', bold = true },

  { section = 'Version control' },
  { 'vc-state-base', fg = 'fg2' },
  { 'vc-up-to-date-state', fg = 'fg2' },
  { 'vc-edited-state', fg = 'yellow' },
  { 'vc-conflict-state', fg = 'red', bold = true },
  { 'vc-locally-added-state', fg = 'green' },
  { 'vc-missing-state', fg = 'red' },
  { 'vc-removed-state', fg = 'red' },
  { 'vc-needs-update-state', fg = 'blue' },
  { 'vc-dir-status-warning', fg = 'yellow' },
  { 'vc-dir-status-ignored', fg = 'fg3' },
  { 'vc-dir-directory', fg = 'blue', bold = true },
  { 'vc-dir-file', fg = 'fg0' },
  { 'vc-dir-mark-indicator', fg = 'accent' },
  { 'diff-hl-insert', fg = 'green', bg = 'diff_add' },
  { 'diff-hl-delete', fg = 'red', bg = 'diff_del' },
  { 'diff-hl-change', fg = 'yellow', bg = 'diff_change' },
  { 'diff-hl-margin-insert', fg = 'green' },
  { 'diff-hl-margin-delete', fg = 'red' },
  { 'diff-hl-margin-change', fg = 'yellow' },
  { 'diff-hl-reverted-hunk-highlight', fg = 'fg0', bg = 'bg5' },
  { 'git-gutter:added', fg = 'green' },
  { 'git-gutter:deleted', fg = 'red' },
  { 'git-gutter:modified', fg = 'yellow' },
  { 'git-gutter:unchanged', fg = 'fg3' },
  { 'git-gutter-fr:added', fg = 'green', bg = 'bg3' },
  { 'git-gutter-fr:deleted', fg = 'red', bg = 'bg3' },
  { 'git-gutter-fr:modified', fg = 'yellow', bg = 'bg3' },
  { 'git-timemachine-minibuffer-author-face', fg = 'accent' },
  { 'git-timemachine-minibuffer-detail-face', fg = 'fg2' },
  { 'git-timemachine-commit', fg = 'purple' },

  { section = 'Ediff' },
  { 'ediff-current-diff-A', bg = 'diff_del', extend = true },
  { 'ediff-current-diff-B', bg = 'diff_add', extend = true },
  { 'ediff-current-diff-C', bg = 'diff_change', extend = true },
  { 'ediff-current-diff-Ancestor', bg = 'bg5', extend = true },
  { 'ediff-even-diff-A', bg = 'bg4', extend = true },
  { 'ediff-even-diff-B', bg = 'bg4', extend = true },
  { 'ediff-even-diff-C', bg = 'bg4', extend = true },
  { 'ediff-even-diff-Ancestor', bg = 'bg4', extend = true },
  { 'ediff-odd-diff-A', bg = 'bg5', extend = true },
  { 'ediff-odd-diff-B', bg = 'bg5', extend = true },
  { 'ediff-odd-diff-C', bg = 'bg5', extend = true },
  { 'ediff-odd-diff-Ancestor', bg = 'bg5', extend = true },
  { 'ediff-fine-diff-A', bg = 'diff_del_inline', extend = true },
  { 'ediff-fine-diff-B', bg = 'diff_add_inline', extend = true },
  { 'ediff-fine-diff-C', bg = 'diff_text', extend = true },
  { 'ediff-fine-diff-Ancestor', bg = 'bg5', extend = true },

  { section = 'Smerge' },
  { 'smerge-base', bg = 'diff_change', extend = true },
  { 'smerge-lower', bg = 'diff_add', extend = true },
  { 'smerge-upper', bg = 'diff_del', extend = true },
  { 'smerge-markers', fg = 'fg2', bg = 'bg4', bold = true, extend = true },
  { 'smerge-refined-added', bg = 'diff_add_inline' },
  { 'smerge-refined-removed', bg = 'diff_del_inline' },
  { 'smerge-refined-changed', bg = 'diff_text' },

  { section = 'Diagnostics' },
  { 'error', fg = 'red', bold = true },
  { 'warning', fg = 'yellow' },
  { 'success', fg = 'green' },
  { 'flymake-error', underline = { style = 'wave', color = 'red' } },
  { 'flymake-warning', underline = { style = 'wave', color = 'yellow' } },
  { 'flymake-note', underline = { style = 'wave', color = 'green' } },
  { 'flymake-error-echo', fg = 'red' },
  { 'flymake-warning-echo', fg = 'yellow' },
  { 'flymake-note-echo', fg = 'green' },
  { 'flymake-error-echo-at-eol', fg = 'red', italic = true },
  { 'flymake-warning-echo-at-eol', fg = 'yellow', italic = true },
  { 'flymake-note-echo-at-eol', fg = 'green', italic = true },
  { 'flycheck-error', underline = { style = 'wave', color = 'red' } },
  { 'flycheck-warning', underline = { style = 'wave', color = 'yellow' } },
  { 'flycheck-info', underline = { style = 'wave', color = 'blue' } },
  { 'flycheck-fringe-error', fg = 'red', bold = true },
  { 'flycheck-fringe-warning', fg = 'yellow', bold = true },
  { 'flycheck-fringe-info', fg = 'blue', bold = true },
  { 'flycheck-error-list-error', fg = 'red', bold = true },
  { 'flycheck-error-list-warning', fg = 'yellow' },
  { 'flycheck-error-list-info', fg = 'blue' },
  { 'flycheck-error-list-id', fg = 'purple' },
  { 'flycheck-error-list-filename', fg = 'accent' },
  { 'flycheck-error-list-line-column', fg = 'fg2' },

  { section = 'LSP' },
  { 'eglot-highlight-symbol-face', bg = 'bg5' },
  { 'eglot-inlay-hint-face', fg = 'fg3', bg = 'bg4', italic = true },
  { 'eglot-parameter-hint-face', fg = 'fg3', bg = 'bg4', italic = true },
  { 'eglot-type-hint-face', fg = 'blue', bg = 'bg4', italic = true },
  { 'eglot-diagnostic-tag-unnecessary-face', fg = 'fg3' },
  { 'eglot-diagnostic-tag-deprecated-face', fg = 'fg2', strike = true },
  { 'lsp-face-highlight-textual', bg = 'bg5' },
  { 'lsp-face-highlight-read', bg = 'bg5' },
  { 'lsp-face-highlight-write', bg = 'bg5', bold = true },
  { 'lsp-ui-doc-background', bg = 'bg0' },
  { 'lsp-ui-doc-border', fg = 'fg3' },
  { 'lsp-ui-doc-header', fg = 'accent', bg = 'bg0', bold = true },
  { 'lsp-ui-sideline-code-action', fg = 'yellow' },
  { 'lsp-ui-sideline-current-symbol', fg = 'fg0', bg = 'bg5' },
  { 'lsp-ui-sideline-symbol-info', fg = 'fg2', italic = true },
  { 'lsp-inlay-hint-face', fg = 'fg3', bg = 'bg4', italic = true },

  { section = 'Completions' },
  { 'completions-common-part', fg = 'accent', bold = true },
  { 'completions-first-difference', fg = 'fg0' },
  { 'completions-annotations', fg = 'fg2', italic = true },
  { 'completions-group-title', fg = 'blue', bold = true },
  { 'completions-group-separator', fg = 'fg3', strike = true },
  { 'completion-preview', fg = 'fg3' },
  { 'completion-preview-exact', fg = 'fg2', underline = true },

  { section = 'Corfu' },
  { 'corfu-default', fg = 'fg0', bg = 'bg1' },
  { 'corfu-current', fg = 'fg0', bg = 'sel', bold = true },
  { 'corfu-bar', bg = 'fg3' },
  { 'corfu-border', bg = 'bg4' },
  { 'corfu-annotations', fg = 'fg2', italic = true },
  { 'corfu-deprecated', fg = 'fg3', strike = true },
  { 'corfu-quick1', fg = 'fg0', bg = 'bg4', bold = true },
  { 'corfu-quick2', fg = 'fg0', bg = 'bg5', bold = true },
  { 'corfu-popupinfo', fg = 'fg0', bg = 'bg0' },

  { section = 'Company' },
  { 'company-tooltip', fg = 'fg0', bg = 'bg1' },
  { 'company-tooltip-selection', fg = 'fg0', bg = 'sel', bold = true },
  { 'company-tooltip-common', fg = 'accent', bold = true },
  { 'company-tooltip-common-selection', fg = 'accent', bg = 'sel', bold = true },
  { 'company-tooltip-annotation', fg = 'fg2', italic = true },
  { 'company-tooltip-annotation-selection', fg = 'fg2', italic = true },
  { 'company-tooltip-search', fg = 'fg0', bg = 'match' },
  { 'company-tooltip-search-selection', fg = 'fg0', bg = 'match' },
  { 'company-tooltip-scrollbar-thumb', bg = 'fg3' },
  { 'company-tooltip-scrollbar-track', bg = 'bg4' },
  { 'company-preview', fg = 'fg2' },
  { 'company-preview-common', fg = 'fg3' },
  { 'company-echo-common', fg = 'accent' },

  { section = 'Vertico / Selectrum' },
  { 'vertico-current', bg = 'sel', extend = true },
  { 'vertico-group-title', fg = 'blue', bold = true, italic = true },
  { 'vertico-group-separator', fg = 'fg3', strike = true },
  { 'vertico-multiline', fg = 'fg2' },

  { section = 'Orderless' },
  { 'orderless-match-face-0', fg = 'accent', bold = true },
  { 'orderless-match-face-1', fg = 'blue', bold = true },
  { 'orderless-match-face-2', fg = 'green', bold = true },
  { 'orderless-match-face-3', fg = 'purple', bold = true },

  { section = 'Marginalia' },
  { 'marginalia-documentation', fg = 'fg2', italic = true },
  { 'marginalia-file-name', fg = 'fg1' },
  { 'marginalia-file-modes', fg = 'fg3' },
  { 'marginalia-file-owner', fg = 'fg2' },
  { 'marginalia-key', fg = 'accent' },
  { 'marginalia-type', fg = 'blue' },
  { 'marginalia-value', fg = 'fg0' },
  { 'marginalia-date', fg = 'cyan' },
  { 'marginalia-number', fg = 'purple' },
  { 'marginalia-string', fg = 'green' },
  { 'marginalia-on', fg = 'green', bold = true },
  { 'marginalia-off', fg = 'red', bold = true },

  { section = 'Consult' },
  { 'consult-file', fg = 'blue' },
  { 'consult-separator', fg = 'fg3' },
  { 'consult-preview-cursor', bg = 'sel' },
  { 'consult-preview-error', bg = 'diff_del' },
  { 'consult-preview-insertion', bg = 'diff_add' },
  { 'consult-line-number', fg = 'fg3' },
  { 'consult-line-number-prefix', fg = 'fg3' },
  { 'consult-grep-context', fg = 'fg2' },
  { 'consult-async-running', fg = 'yellow' },
  { 'consult-async-failed', fg = 'red' },
  { 'consult-async-finished', fg = 'green' },
  { 'consult-async-split', fg = 'fg3' },

  { section = 'Embark' },
  { 'embark-target', fg = 'fg0', bg = 'bg5', underline = true },
  { 'embark-collect-marked', fg = 'accent', bg = 'bg4' },
  { 'embark-collect-candidate', fg = 'fg0' },
  { 'embark-selected', bg = 'sel' },

  { section = 'Ivy' },
  { 'ivy-current-match', fg = 'fg0', bg = 'sel', bold = true, extend = true },
  { 'ivy-minibuffer-match-face-1', fg = 'fg2' },
  { 'ivy-minibuffer-match-face-2', fg = 'accent', bold = true },
  { 'ivy-minibuffer-match-face-3', fg = 'blue', bold = true },
  { 'ivy-minibuffer-match-face-4', fg = 'purple', bold = true },
  { 'ivy-confirm-face', fg = 'green' },
  { 'ivy-match-required-face', fg = 'red' },
  { 'ivy-virtual', fg = 'fg2', italic = true },
  { 'ivy-subdir', fg = 'blue', bold = true },
  { 'ivy-org', fg = 'fg1' },
  { 'ivy-separator', fg = 'fg3' },
  { 'ivy-action', fg = 'accent' },
  { 'ivy-prompt-match', fg = 'fg0', bg = 'match' },

  { section = 'Xref' },
  { 'xref-match', fg = 'fg0', bg = 'match', bold = true },
  { 'xref-file-header', fg = 'accent', bold = true },
  { 'xref-line-number', fg = 'fg3' },

  { section = 'Info' },
  { 'info-menu-header', fg = 'accent', bold = true },
  { 'info-menu-star', fg = 'red' },
  { 'info-node', fg = 'accent', bold = true, italic = true },
  { 'info-title-1', fg = 'accent', bold = true, height = 1.4 },
  { 'info-title-2', fg = 'accent2', bold = true, height = 1.3 },
  { 'info-title-3', fg = 'blue', bold = true, height = 1.2 },
  { 'info-title-4', fg = 'fg0', bold = true, height = 1.1 },
  { 'info-xref', fg = 'blue', underline = true },
  { 'info-xref-visited', fg = 'purple', underline = true },
  { 'info-index-match', fg = 'fg0', bg = 'match' },
  { 'info-header-xref', fg = 'blue', underline = true },

  { section = 'Help' },
  { 'help-argument-name', fg = 'accent', italic = true },
  { 'help-key-binding', fg = 'fg0', bg = 'bg4', box = { line_width = -1, color = 'fg3' } },

  { section = 'Helpful' },
  { 'helpful-heading', fg = 'accent', bold = true },

  { section = 'Describe' },
  { 'describe-variable-value', fg = 'green' },

  { section = 'Eldoc' },
  { 'eldoc-highlight-function-argument', fg = 'accent', bold = true },

  { section = 'Dired' },
  { 'dired-directory', fg = 'blue', bold = true },
  { 'dired-flagged', fg = 'red', bold = true },
  { 'dired-header', fg = 'accent', bold = true },
  { 'dired-ignored', fg = 'fg3' },
  { 'dired-mark', fg = 'accent' },
  { 'dired-marked', fg = 'yellow', bold = true },
  { 'dired-perm-write', fg = 'yellow' },
  { 'dired-set-id', fg = 'red' },
  { 'dired-special', fg = 'purple' },
  { 'dired-symlink', fg = 'cyan', italic = true },
  { 'dired-warning', fg = 'yellow', bold = true },
  { 'dired-broken-symlink', fg = 'red', italic = true, strike = true },
  { 'diredfl-dir-name', fg = 'blue', bold = true },
  { 'diredfl-dir-heading', fg = 'accent', bold = true },
  { 'diredfl-dir-priv', fg = 'blue' },
  { 'diredfl-exec-priv', fg = 'green' },
  { 'diredfl-file-name', fg = 'fg0' },
  { 'diredfl-file-suffix', fg = 'fg2' },
  { 'diredfl-flag-mark', fg = 'accent', bold = true },
  { 'diredfl-flag-mark-line', bg = 'bg4', extend = true },
  { 'diredfl-ignored-file-name', fg = 'fg3' },
  { 'diredfl-link-priv', fg = 'cyan' },
  { 'diredfl-no-priv', fg = 'fg3' },
  { 'diredfl-number', fg = 'purple' },
  { 'diredfl-read-priv', fg = 'yellow' },
  { 'diredfl-symlink', fg = 'cyan', italic = true },
  { 'diredfl-write-priv', fg = 'red' },

  { section = 'Ibuffer' },
  { 'ibuffer-locked-buffer', fg = 'yellow' },
  { 'ibuffer-filter-group-name', fg = 'accent', bold = true },
  { 'ibuffer-deletion', fg = 'red' },
  { 'ibuffer-marked', fg = 'yellow', bold = true },

  { section = 'Treemacs / Neotree' },
  { 'treemacs-root-face', fg = 'accent', bold = true, height = 1.1 },
  { 'treemacs-directory-face', fg = 'blue', bold = true },
  { 'treemacs-file-face', fg = 'fg0' },
  { 'treemacs-git-modified-face', fg = 'yellow' },
  { 'treemacs-git-renamed-face', fg = 'cyan' },
  { 'treemacs-git-ignored-face', fg = 'fg3' },
  { 'treemacs-git-untracked-face', fg = 'fg2' },
  { 'treemacs-git-added-face', fg = 'green' },
  { 'treemacs-git-conflict-face', fg = 'red', bold = true },
  { 'treemacs-tags-face', fg = 'fg2' },
  { 'neo-root-dir-face', fg = 'accent', bold = true },
  { 'neo-dir-link-face', fg = 'blue', bold = true },
  { 'neo-file-link-face', fg = 'fg0' },
  { 'neo-expand-btn-face', fg = 'fg2' },
  { 'neo-banner-face', fg = 'accent' },

  { section = 'Magit' },
  { 'magit-section-heading', fg = 'accent', bold = true },
  { 'magit-section-heading-selection', fg = 'accent2', bold = true },
  { 'magit-section-highlight', bg = 'bg5', extend = true },
  { 'magit-section-secondary-heading', fg = 'fg1', bold = true },
  { 'magit-diff-added', fg = 'bright_green', bg = 'diff_add', extend = true },
  { 'magit-diff-removed', fg = 'red', bg = 'diff_del', extend = true },
  { 'magit-diff-base', fg = 'yellow', bg = 'diff_change', extend = true },
  { 'magit-diff-added-highlight', fg = 'bright_green', bg = 'diff_add_inline', extend = true },
  { 'magit-diff-removed-highlight', fg = 'red', bg = 'diff_del_inline', extend = true },
  { 'magit-diff-base-highlight', fg = 'yellow', bg = 'diff_text', extend = true },
  { 'magit-diff-context', fg = 'fg2', extend = true },
  { 'magit-diff-context-highlight', fg = 'fg1', bg = 'bg5', extend = true },
  { 'magit-diff-hunk-heading', fg = 'cyan', bg = 'diff_change', extend = true },
  { 'magit-diff-hunk-heading-highlight', fg = 'bright_cyan', bg = 'diff_text', bold = true, extend = true },
  { 'magit-diff-hunk-heading-selection', fg = 'fg0', bg = 'bg5', extend = true },
  { 'magit-diff-hunk-region', extend = true },
  { 'magit-diff-lines-heading', fg = 'fg0', bg = 'bg4', extend = true },
  { 'magit-diff-lines-boundary', bg = 'bg4', extend = true },
  { 'magit-diff-whitespace-warning', bg = 'diff_del' },
  { 'magit-diffstat-added', fg = 'green' },
  { 'magit-diffstat-removed', fg = 'red' },
  { 'magit-branch-local', fg = 'blue' },
  { 'magit-branch-remote', fg = 'green' },
  { 'magit-branch-remote-head', fg = 'bright_green', box = true },
  { 'magit-branch-current', fg = 'blue', box = true },
  { 'magit-branch-upstream', fg = 'fg2', italic = true },
  { 'magit-branch-warning', fg = 'yellow', bold = true },
  { 'magit-tag', fg = 'yellow' },
  { 'magit-hash', fg = 'fg3' },
  { 'magit-filename', fg = 'fg0' },
  { 'magit-log-author', fg = 'accent' },
  { 'magit-log-date', fg = 'fg2' },
  { 'magit-log-graph', fg = 'fg3' },
  { 'magit-log-head-label-head', fg = 'fg0', bg = 'accent', bold = true },
  { 'magit-process-ok', fg = 'green', bold = true },
  { 'magit-process-ng', fg = 'red', bold = true },
  { 'magit-reflog-commit', fg = 'green' },
  { 'magit-reflog-amend', fg = 'purple' },
  { 'magit-reflog-merge', fg = 'cyan' },
  { 'magit-reflog-checkout', fg = 'blue' },
  { 'magit-reflog-reset', fg = 'red' },
  { 'magit-reflog-rebase', fg = 'purple' },
  { 'magit-reflog-cherry-pick', fg = 'green' },
  { 'magit-reflog-remote', fg = 'cyan' },
  { 'magit-reflog-other', fg = 'fg2' },
  { 'magit-signature-good', fg = 'green' },
  { 'magit-signature-bad', fg = 'red', bold = true },
  { 'magit-signature-untrusted', fg = 'yellow' },
  { 'magit-signature-expired', fg = 'yellow' },
  { 'magit-signature-revoked', fg = 'red' },
  { 'magit-signature-error', fg = 'red' },
  { 'magit-cherry-equivalent', fg = 'cyan' },
  { 'magit-cherry-unmatched', fg = 'purple' },
  { 'magit-blame-heading', fg = 'fg1', bg = 'bg2', extend = true },
  { 'magit-blame-hash', fg = 'accent', bg = 'bg2' },
  { 'magit-blame-name', fg = 'accent2', bg = 'bg2' },
  { 'magit-blame-date', fg = 'fg2', bg = 'bg2' },
  { 'magit-blame-summary', fg = 'fg0', bg = 'bg2' },
  { 'magit-blame-margin', fg = 'fg2', bg = 'bg2' },
  { 'magit-blame-dimmed', fg = 'fg3', bg = 'bg2' },

  { section = 'Git commit' },
  { 'git-commit-summary', fg = 'fg0', bold = true },
  { 'git-commit-overlong-summary', fg = 'red', underline = true },
  { 'git-commit-nonempty-second-line', fg = 'red', underline = true },
  { 'git-commit-comment-heading', fg = 'accent', bold = true },
  { 'git-commit-comment-action', fg = 'green' },
  { 'git-commit-comment-branch-local', fg = 'blue' },
  { 'git-commit-comment-branch-remote', fg = 'green' },
  { 'git-commit-comment-file', fg = 'accent' },
  { 'git-commit-keyword', fg = 'purple' },
  { 'git-commit-trailer-token', fg = 'blue' },
  { 'git-commit-trailer-value', fg = 'fg0' },

  { section = 'Git rebase' },
  { 'git-rebase-pick', fg = 'green' },
  { 'git-rebase-reword', fg = 'blue' },
  { 'git-rebase-edit', fg = 'yellow' },
  { 'git-rebase-squash', fg = 'purple' },
  { 'git-rebase-fixup', fg = 'accent2' },
  { 'git-rebase-exec', fg = 'cyan' },
  { 'git-rebase-kill-line', fg = 'red', strike = true },
  { 'git-rebase-hash', fg = 'fg3' },
  { 'git-rebase-description', fg = 'fg0' },
  { 'git-rebase-label', fg = 'fg2' },

  { section = 'Forge' },
  { 'forge-topic-label', box = true },
  { 'forge-pullreq-open', fg = 'green' },
  { 'forge-pullreq-merged', fg = 'purple' },
  { 'forge-pullreq-closed', fg = 'red' },
  { 'forge-issue-open', fg = 'green' },
  { 'forge-issue-closed', fg = 'fg3' },
  { 'forge-issue-completed', fg = 'fg3', strike = true },
  { 'forge-post-author', fg = 'accent', bold = true },

  { section = 'Transient' },
  { 'transient-heading', fg = 'accent', bold = true },
  { 'transient-key', fg = 'cyan', bold = true },
  { 'transient-argument', fg = 'yellow', bold = true },
  { 'transient-value', fg = 'green' },
  { 'transient-inactive-argument', fg = 'fg3' },
  { 'transient-inactive-value', fg = 'fg3' },
  { 'transient-enabled-suffix', fg = 'green', bold = true },
  { 'transient-disabled-suffix', fg = 'red', bold = true },
  { 'transient-inapt-suffix', fg = 'fg3', italic = true },
  { 'transient-mismatched-key', fg = 'red', underline = true },
  { 'transient-nonstandard-key', fg = 'yellow', underline = true },
  { 'transient-unreachable', fg = 'fg3' },
  { 'transient-unreachable-key', fg = 'fg3', underline = true },
  { 'transient-separator', fg = 'fg3', strike = true, extend = true },
  { 'transient-amaranth', fg = 'red', bold = true },
  { 'transient-blue', fg = 'blue', bold = true },
  { 'transient-pink', fg = 'bright_purple', bold = true },
  { 'transient-purple', fg = 'purple', bold = true },
  { 'transient-teal', fg = 'cyan', bold = true },
  { 'transient-red', fg = 'red', bold = true },

  { section = 'Which-key' },
  { 'which-key-key-face', fg = 'accent', bold = true },
  { 'which-key-separator-face', fg = 'fg3' },
  { 'which-key-note-face', fg = 'fg2', italic = true },
  { 'which-key-command-description-face', fg = 'fg0' },
  { 'which-key-group-description-face', fg = 'blue', bold = true },
  { 'which-key-highlighted-command-face', fg = 'accent', underline = true },
  { 'which-key-local-map-description-face', fg = 'bright_green' },
  { 'which-key-special-key-face', fg = 'purple', bold = true },
  { 'which-key-docstring-face', fg = 'fg2', italic = true },

  { section = 'Hydra' },
  { 'hydra-face-red', fg = 'red', bold = true },
  { 'hydra-face-blue', fg = 'blue', bold = true },
  { 'hydra-face-amaranth', fg = 'yellow', bold = true },
  { 'hydra-face-pink', fg = 'bright_purple', bold = true },
  { 'hydra-face-teal', fg = 'cyan', bold = true },

  { section = 'Avy' },
  { 'avy-lead-face', fg = 'bg3', bg = 'accent', bold = true },
  { 'avy-lead-face-0', fg = 'bg3', bg = 'blue', bold = true },
  { 'avy-lead-face-1', fg = 'bg3', bg = 'fg2', bold = true },
  { 'avy-lead-face-2', fg = 'bg3', bg = 'purple', bold = true },
  { 'avy-background-face', fg = 'fg3' },

  { section = 'hl-todo' },
  { 'hl-todo', bold = true, italic = true },

  { section = 'Pulsar / Pulse' },
  { 'pulsar-red', bg = 'diff_del', extend = true },
  { 'pulsar-green', bg = 'diff_add', extend = true },
  { 'pulsar-yellow', bg = 'diff_text', extend = true },
  { 'pulsar-blue', bg = 'diff_change', extend = true },
  { 'pulsar-cyan', bg = 'diff_change', extend = true },
  { 'pulsar-magenta', bg = 'diff_del', extend = true },
  { 'pulse-highlight-start-face', bg = 'match', extend = true },
  { 'pulse-highlight-face', bg = 'bg5', extend = true },

  { section = 'Org mode' },
  { 'org-level-1', fg = 'accent', bold = true },
  { 'org-level-2', fg = 'accent2', bold = true },
  { 'org-level-3', fg = 'blue', bold = true },
  { 'org-level-4', fg = 'green', bold = true },
  { 'org-level-5', fg = 'cyan', bold = true },
  { 'org-level-6', fg = 'purple', bold = true },
  { 'org-level-7', fg = 'yellow', bold = true },
  { 'org-level-8', fg = 'red', bold = true },
  { 'org-document-title', fg = 'accent', bold = true },
  { 'org-document-info', fg = 'fg2' },
  { 'org-document-info-keyword', fg = 'fg3' },
  { 'org-block', fg = 'fg0', bg = 'bg2', extend = true },
  { 'org-block-begin-line', fg = 'fg3', bg = 'bg2', italic = true, extend = true },
  { 'org-block-end-line', fg = 'fg3', bg = 'bg2', italic = true, extend = true },
  { 'org-code', fg = 'green', bg = 'bg2' },
  { 'org-verbatim', fg = 'cyan', bg = 'bg2' },
  { 'org-meta-line', fg = 'fg3' },
  { 'org-drawer', fg = 'fg3' },
  { 'org-property-value', fg = 'fg2' },
  { 'org-special-keyword', fg = 'accent2' },
  { 'org-tag', fg = 'fg3', bold = true },
  { 'org-tag-group', fg = 'fg2', bold = true },
  { 'org-ellipsis', fg = 'fg3', underline = false },
  { 'org-hide', fg = 'bg3' },
  { 'org-link', fg = 'blue', underline = true },
  { 'org-footnote', fg = 'cyan', underline = true },
  { 'org-target', fg = 'fg2', underline = true },
  { 'org-date', fg = 'cyan' },
  { 'org-date-selected', fg = 'bg3', bg = 'cyan' },
  { 'org-sexp-date', fg = 'cyan' },
  { 'org-time-grid', fg = 'fg3' },
  { 'org-todo', fg = 'red', bold = true },
  { 'org-done', fg = 'green', bold = true },
  { 'org-headline-todo', fg = 'fg0' },
  { 'org-headline-done', fg = 'fg2', strike = true },
  { 'org-priority', fg = 'purple' },
  { 'org-checkbox', fg = 'accent2', bold = true },
  { 'org-checkbox-statistics-todo', fg = 'yellow', bold = true },
  { 'org-checkbox-statistics-done', fg = 'green', bold = true },
  { 'org-table', fg = 'blue' },
  { 'org-table-header', fg = 'fg0', bg = 'bg4', bold = true },
  { 'org-formula', fg = 'yellow' },
  { 'org-list-dt', fg = 'accent2', bold = true },
  { 'org-scheduled', fg = 'green' },
  { 'org-scheduled-previously', fg = 'yellow' },
  { 'org-scheduled-today', fg = 'bright_green' },
  { 'org-upcoming-deadline', fg = 'yellow' },
  { 'org-imminent-deadline', fg = 'red', bold = true },
  { 'org-warning', fg = 'yellow', bold = true },
  { 'org-default', fg = 'fg0', bg = 'bg3' },
  { 'org-quote', fg = 'fg1', bg = 'bg2', italic = true, extend = true },
  { 'org-verse', fg = 'fg1', bg = 'bg2', italic = true, extend = true },
  { 'org-latex-and-related', fg = 'purple' },
  { 'org-macro', fg = 'accent' },
  { 'org-mode-line-clock', fg = 'fg1' },
  { 'org-mode-line-clock-overrun', fg = 'red', bold = true },

  { section = 'Org Agenda' },
  { 'org-agenda-structure', fg = 'accent', bold = true },
  { 'org-agenda-structure-filter', fg = 'accent2' },
  { 'org-agenda-date', fg = 'blue', bold = true },
  { 'org-agenda-date-today', fg = 'accent', bold = true, underline = true },
  { 'org-agenda-date-weekend', fg = 'fg2' },
  { 'org-agenda-date-weekend-today', fg = 'accent2', underline = true },
  { 'org-agenda-current-time', fg = 'accent2', bold = true },
  { 'org-agenda-done', fg = 'fg2', strike = true },
  { 'org-agenda-dimmed-todo-face', fg = 'fg3' },
  { 'org-agenda-restriction-lock', fg = 'fg0', bg = 'yellow' },
  { 'org-agenda-clocking', fg = 'fg0', bg = 'bg4' },
  { 'org-agenda-diary', fg = 'fg2' },
  { 'org-agenda-calendar-event', fg = 'fg0' },
  { 'org-agenda-calendar-sexp', fg = 'fg2' },
  { 'org-agenda-filter-category', fg = 'yellow', bold = true },
  { 'org-agenda-filter-regexp', fg = 'yellow', bold = true },
  { 'org-agenda-filter-tags', fg = 'yellow', bold = true },
  { 'org-agenda-filter-effort', fg = 'yellow', bold = true },
  { 'org-agenda-column-dateline', fg = 'cyan' },

  { section = 'Org Roam' },
  { 'org-roam-link', fg = 'blue', underline = true },
  { 'org-roam-link-current', fg = 'accent', underline = true },
  { 'org-roam-link-invalid', fg = 'red', underline = true },
  { 'org-roam-header-line', fg = 'accent', bold = true },
  { 'org-roam-olp', fg = 'fg2', italic = true },
  { 'org-roam-preview-heading', fg = 'accent2', bold = true },

  { section = 'Markdown' },
  { 'markdown-header-face', fg = 'accent', bold = true },
  { 'markdown-header-face-1', fg = 'accent', bold = true },
  { 'markdown-header-face-2', fg = 'accent2', bold = true },
  { 'markdown-header-face-3', fg = 'blue', bold = true },
  { 'markdown-header-face-4', fg = 'green', bold = true },
  { 'markdown-header-face-5', fg = 'cyan', bold = true },
  { 'markdown-header-face-6', fg = 'purple', bold = true },
  { 'markdown-header-delimiter-face', fg = 'fg3', bold = true },
  { 'markdown-bold-face', bold = true },
  { 'markdown-italic-face', italic = true },
  { 'markdown-strike-through-face', fg = 'fg2', strike = true },
  { 'markdown-code-face', fg = 'fg0', bg = 'bg2', extend = true },
  { 'markdown-inline-code-face', fg = 'green', bg = 'bg2' },
  { 'markdown-pre-face', fg = 'fg0', bg = 'bg2' },
  { 'markdown-language-keyword-face', fg = 'fg3' },
  { 'markdown-blockquote-face', fg = 'fg2', italic = true },
  { 'markdown-list-face', fg = 'accent2' },
  { 'markdown-link-face', fg = 'blue', underline = true },
  { 'markdown-url-face', fg = 'cyan' },
  { 'markdown-plain-url-face', fg = 'cyan', underline = true },
  { 'markdown-reference-face', fg = 'fg2' },
  { 'markdown-footnote-marker-face', fg = 'purple' },
  { 'markdown-footnote-text-face', fg = 'fg1' },
  { 'markdown-table-face', fg = 'blue' },
  { 'markdown-hr-face', fg = 'fg3' },
  { 'markdown-html-attr-name-face', fg = 'blue' },
  { 'markdown-html-attr-value-face', fg = 'green' },
  { 'markdown-html-tag-delimiter-face', fg = 'fg2' },
  { 'markdown-html-tag-name-face', fg = 'accent' },
  { 'markdown-math-face', fg = 'purple' },
  { 'markdown-metadata-key-face', fg = 'fg2' },
  { 'markdown-metadata-value-face', fg = 'fg1' },
  { 'markdown-highlighting-face', bg = 'match' },

  { section = 'Shell / Terminal' },
  { 'comint-highlight-input', fg = 'fg0', bold = true },
  { 'comint-highlight-prompt', fg = 'green', bold = true },
  { 'eshell-prompt', fg = 'accent', bold = true },
  { 'eshell-ls-directory', fg = 'blue', bold = true },
  { 'eshell-ls-executable', fg = 'green' },
  { 'eshell-ls-missing', fg = 'red', bold = true },
  { 'eshell-ls-product', fg = 'yellow' },
  { 'eshell-ls-readonly', fg = 'fg2' },
  { 'eshell-ls-special', fg = 'purple' },
  { 'eshell-ls-symlink', fg = 'cyan' },
  { 'eshell-ls-unreadable', fg = 'red' },
  { 'eshell-ls-backup', fg = 'fg3' },
  { 'eshell-ls-clutter', fg = 'fg3' },
  { 'eshell-ls-archive', fg = 'yellow' },
  { 'vterm-color-default', fg = 'fg0', bg = 'bg3' },
  { 'vterm-color-black', fg = 'bg1', bg = 'bg1' },
  { 'vterm-color-red', fg = 'red', bg = 'red' },
  { 'vterm-color-green', fg = 'green', bg = 'green' },
  { 'vterm-color-yellow', fg = 'yellow', bg = 'yellow' },
  { 'vterm-color-blue', fg = 'blue', bg = 'blue' },
  { 'vterm-color-magenta', fg = 'purple', bg = 'purple' },
  { 'vterm-color-cyan', fg = 'cyan', bg = 'cyan' },
  { 'vterm-color-white', fg = 'fg1', bg = 'fg1' },
  { 'vterm-color-bright-black', fg = 'fg3', bg = 'fg3' },
  { 'vterm-color-bright-red', fg = 'accent', bg = 'accent' },
  { 'vterm-color-bright-green', fg = 'bright_green', bg = 'bright_green' },
  { 'vterm-color-bright-yellow', fg = 'accent2', bg = 'accent2' },
  { 'vterm-color-bright-blue', fg = 'bright_blue', bg = 'bright_blue' },
  { 'vterm-color-bright-magenta', fg = 'bright_purple', bg = 'bright_purple' },
  { 'vterm-color-bright-cyan', fg = 'bright_cyan', bg = 'bright_cyan' },
  { 'vterm-color-bright-white', fg = 'fg0', bg = 'fg0' },

  { section = 'Ansi colors' },
  { 'ansi-color-black', fg = 'bg1', bg = 'bg1' },
  { 'ansi-color-red', fg = 'red', bg = 'red' },
  { 'ansi-color-green', fg = 'green', bg = 'green' },
  { 'ansi-color-yellow', fg = 'yellow', bg = 'yellow' },
  { 'ansi-color-blue', fg = 'blue', bg = 'blue' },
  { 'ansi-color-magenta', fg = 'purple', bg = 'purple' },
  { 'ansi-color-cyan', fg = 'cyan', bg = 'cyan' },
  { 'ansi-color-white', fg = 'fg1', bg = 'fg1' },
  { 'ansi-color-bright-black', fg = 'fg3', bg = 'fg3' },
  { 'ansi-color-bright-red', fg = 'accent', bg = 'accent' },
  { 'ansi-color-bright-green', fg = 'bright_green', bg = 'bright_green' },
  { 'ansi-color-bright-yellow', fg = 'accent2', bg = 'accent2' },
  { 'ansi-color-bright-blue', fg = 'bright_blue', bg = 'bright_blue' },
  { 'ansi-color-bright-magenta', fg = 'bright_purple', bg = 'bright_purple' },
  { 'ansi-color-bright-cyan', fg = 'bright_cyan', bg = 'bright_cyan' },
  { 'ansi-color-bright-white', fg = 'fg0', bg = 'fg0' },

  { section = 'Calendar' },
  { 'calendar-today', fg = 'accent', bold = true, underline = true },
  { 'calendar-month-header', fg = 'accent', bold = true },
  { 'calendar-weekday-header', fg = 'blue' },
  { 'calendar-weekend-header', fg = 'fg2' },
  { 'diary', fg = 'yellow' },
  { 'holiday', fg = 'red' },
  { 'diary-anniversary', fg = 'cyan' },

  { section = 'Message / Mail' },
  { 'message-header-name', fg = 'blue', bold = true },
  { 'message-header-to', fg = 'fg0', bold = true },
  { 'message-header-cc', fg = 'fg1' },
  { 'message-header-subject', fg = 'accent', bold = true },
  { 'message-header-other', fg = 'fg1' },
  { 'message-header-newsgroups', fg = 'yellow', bold = true },
  { 'message-header-xheader', fg = 'fg2' },
  { 'message-separator', fg = 'fg3', italic = true },
  { 'message-cited-text-1', fg = 'blue' },
  { 'message-cited-text-2', fg = 'green' },
  { 'message-cited-text-3', fg = 'purple' },
  { 'message-cited-text-4', fg = 'cyan' },
  { 'message-mml', fg = 'fg2', italic = true },

  { section = 'Gnus' },
  { 'gnus-group-mail-1', fg = 'accent', bold = true },
  { 'gnus-group-mail-2', fg = 'accent' },
  { 'gnus-group-mail-3', fg = 'fg1' },
  { 'gnus-group-mail-1-empty', fg = 'fg2' },
  { 'gnus-group-mail-2-empty', fg = 'fg2' },
  { 'gnus-group-mail-3-empty', fg = 'fg3' },
  { 'gnus-group-news-1', fg = 'blue', bold = true },
  { 'gnus-group-news-2', fg = 'blue' },
  { 'gnus-group-news-3', fg = 'fg1' },
  { 'gnus-summary-selected', fg = 'fg0', bg = 'sel' },
  { 'gnus-summary-normal-read', fg = 'fg2' },
  { 'gnus-summary-normal-unread', fg = 'fg0', bold = true },
  { 'gnus-summary-high-unread', fg = 'accent', bold = true },
  { 'gnus-summary-low-unread', fg = 'fg2', italic = true },
  { 'gnus-header-name', fg = 'blue', bold = true },
  { 'gnus-header-from', fg = 'accent' },
  { 'gnus-header-subject', fg = 'fg0', bold = true },
  { 'gnus-header-content', fg = 'fg1' },

  { section = 'Notmuch' },
  { 'notmuch-search-date', fg = 'fg3' },
  { 'notmuch-search-count', fg = 'fg3' },
  { 'notmuch-search-subject', fg = 'fg0' },
  { 'notmuch-search-matching-authors', fg = 'accent' },
  { 'notmuch-search-non-matching-authors', fg = 'fg2' },
  { 'notmuch-search-flagged-face', fg = 'blue' },
  { 'notmuch-search-unread-face', bold = true },
  { 'notmuch-tag-face', fg = 'green' },
  { 'notmuch-tag-unread', fg = 'yellow', bold = true },
  { 'notmuch-tag-flagged', fg = 'blue' },
  { 'notmuch-tag-deleted', fg = 'red', strike = true },
  { 'notmuch-tree-match-face', fg = 'fg0', bold = true },
  { 'notmuch-tree-no-match-face', fg = 'fg2' },
  { 'notmuch-message-summary-face', fg = 'fg2', bg = 'bg2' },

  { section = 'Elfeed' },
  { 'elfeed-search-date-face', fg = 'fg3' },
  { 'elfeed-search-feed-face', fg = 'blue' },
  { 'elfeed-search-filter-face', fg = 'accent', bold = true },
  { 'elfeed-search-last-update-face', fg = 'fg3', italic = true },
  { 'elfeed-search-tag-face', fg = 'green' },
  { 'elfeed-search-title-face', fg = 'fg0' },
  { 'elfeed-search-unread-title-face', fg = 'fg0', bold = true },
  { 'elfeed-search-unread-count-face', fg = 'accent2', bold = true },
  { 'elfeed-log-error-level-face', fg = 'red' },
  { 'elfeed-log-warn-level-face', fg = 'yellow' },
  { 'elfeed-log-info-level-face', fg = 'blue' },
  { 'elfeed-log-debug-level-face', fg = 'fg2' },

  { section = 'EWW' },
  { 'eww-valid-certificate', fg = 'green', bold = true },
  { 'eww-invalid-certificate', fg = 'red', bold = true },
  { 'eww-form-checkbox', fg = 'fg0', bg = 'bg4', box = true },
  { 'eww-form-file', fg = 'fg0', bg = 'bg4', box = true },
  { 'eww-form-select', fg = 'fg0', bg = 'bg4', box = true },
  { 'eww-form-submit', fg = 'fg0', bg = 'bg4', bold = true, box = true },
  { 'eww-form-text', fg = 'fg0', bg = 'bg4', box = true },
  { 'eww-form-textarea', fg = 'fg0', bg = 'bg4', box = true },
  { 'shr-link', fg = 'blue', underline = true },
  { 'shr-visited-link', fg = 'purple', underline = true },
  { 'shr-selected-link', fg = 'bg3', bg = 'blue' },
  { 'shr-strike-through', fg = 'fg2', strike = true },
  { 'shr-abbreviation', underline = { style = 'dots', color = 'fg2' } },
  { 'shr-h1', fg = 'accent', bold = true },
  { 'shr-h2', fg = 'accent2', bold = true },
  { 'shr-h3', fg = 'blue', bold = true },
  { 'shr-h4', fg = 'fg0', bold = true },
  { 'shr-h5', fg = 'fg1', bold = true },
  { 'shr-h6', fg = 'fg2', bold = true },
  { 'shr-code', fg = 'green', bg = 'bg2' },

  { section = 'CIDER' },
  { 'cider-result-overlay-face', fg = 'fg0', bg = 'bg4', box = { line_width = -1, color = 'fg3' } },
  { 'cider-debug-code-overlay-face', bg = 'bg5' },
  { 'cider-error-highlight-face', underline = { style = 'wave', color = 'red' } },
  { 'cider-warning-highlight-face', underline = { style = 'wave', color = 'yellow' } },
  { 'cider-repl-prompt-face', fg = 'green', bold = true },
  { 'cider-repl-input-face', bold = true },
  { 'cider-repl-output-face', fg = 'fg1' },
  { 'cider-repl-stderr-face', fg = 'red' },
  { 'cider-test-success-face', fg = 'bg3', bg = 'green' },
  { 'cider-test-failure-face', fg = 'bg3', bg = 'red' },
  { 'cider-test-error-face', fg = 'bg3', bg = 'yellow' },
  { 'cider-test-skipped-face', fg = 'bg3', bg = 'fg2' },
  { 'cider-fringe-good-face', fg = 'green' },
  { 'cider-enlightened-face', fg = 'yellow', box = { line_width = -1, color = 'yellow' } },
  { 'cider-enlightened-local-face', fg = 'yellow', bold = true },
  { 'cider-traced-face', box = { line_width = -1, color = 'cyan' } },
  { 'cider-stacktrace-error-message-face', fg = 'red' },
  { 'cider-stacktrace-filter-active-face', fg = 'fg0', underline = true },
  { 'cider-stacktrace-filter-inactive-face', fg = 'fg2' },

  { section = 'SLIME / SLY' },
  { 'slime-repl-prompt-face', fg = 'green', bold = true },
  { 'slime-repl-output-face', fg = 'fg1' },
  { 'slime-repl-inputed-output-face', fg = 'fg2' },
  { 'slime-error-face', underline = { style = 'wave', color = 'red' } },
  { 'slime-warning-face', underline = { style = 'wave', color = 'yellow' } },
  { 'slime-style-warning-face', underline = { style = 'wave', color = 'blue' } },
  { 'slime-note-face', underline = { style = 'wave', color = 'green' } },
  { 'sly-mrepl-prompt-face', fg = 'green', bold = true },
  { 'sly-mrepl-output-face', fg = 'fg1' },
  { 'sly-mrepl-note-face', fg = 'fg3' },
  { 'sly-stickers-placed-face', bg = 'bg5' },

  { section = 'Package menu' },
  { 'package-name', fg = 'blue' },
  { 'package-description', fg = 'fg1' },
  { 'package-status-available', fg = 'green' },
  { 'package-status-avail-obso', fg = 'fg2' },
  { 'package-status-installed', fg = 'fg0', bold = true },
  { 'package-status-dependency', fg = 'blue' },
  { 'package-status-built-in', fg = 'fg2' },
  { 'package-status-new', fg = 'accent', bold = true },
  { 'package-status-held', fg = 'yellow' },
  { 'package-status-external', fg = 'cyan' },
  { 'package-status-incompat', fg = 'red' },
  { 'package-status-disabled', fg = 'fg3', strike = true },

  { section = 'Custom / Customize' },
  { 'custom-group-tag', fg = 'accent', bold = true },
  { 'custom-group-tag-1', fg = 'blue', bold = true },
  { 'custom-variable-tag', fg = 'accent2', bold = true },
  { 'custom-variable-obsolete', fg = 'fg2', strike = true },
  { 'custom-state', fg = 'green' },
  { 'custom-changed', fg = 'yellow' },
  { 'custom-modified', fg = 'yellow', bold = true },
  { 'custom-set', fg = 'blue' },
  { 'custom-themed', fg = 'blue' },
  { 'custom-saved', fg = 'green', bold = true },
  { 'custom-rogue', fg = 'red', bg = 'bg4' },
  { 'custom-invalid', fg = 'fg0', bg = 'red' },
  { 'custom-comment', fg = 'fg2', bg = 'bg2' },
  { 'custom-comment-tag', fg = 'fg2' },
  { 'custom-button', fg = 'fg0', bg = 'bg4', box = true },
  { 'custom-button-mouse', fg = 'fg0', bg = 'bg5', box = true },
  { 'custom-button-pressed', fg = 'bg3', bg = 'accent', box = true },
  { 'custom-documentation', italic = true },
  { 'widget-field', fg = 'fg0', bg = 'bg4' },
  { 'widget-button', fg = 'blue', bold = true },
  { 'widget-button-pressed', fg = 'accent' },
  { 'widget-documentation', fg = 'fg2', italic = true },
  { 'widget-inactive', fg = 'fg3' },
  { 'widget-single-line-field', fg = 'fg0', bg = 'bg4' },
}

-- Face name column: names are padded to this column before `((,class`.
-- Names longer than this get one space of separation and overflow.
local EMACS_NAME_COL = 34

-- Canonical emission order for face attributes.
local EMACS_ATTR_ORDER = {
  'fg',
  'bg',
  'bold',
  'italic',
  'underline',
  'strike',
  'extend',
  'box',
  'height',
}

-- Precomputed dash line for section headers. 70 U+2500 chars (210 bytes).
local EMACS_DASH_LINE = string.rep('─', 70)

local EMACS_SECTION_PREFIX = '   ;; ── '
local EMACS_SECTION_PREFIX_COLS = 9 -- visible columns (each ─ is 1 col, 3 bytes)

do
  local cols = 0
  for i = 1, #EMACS_SECTION_PREFIX do
    local b = EMACS_SECTION_PREFIX:byte(i)
    if b < 0x80 or b >= 0xC0 then
      cols = cols + 1
    end
  end
  assert(cols == EMACS_SECTION_PREFIX_COLS, 'EMACS_SECTION_PREFIX_COLS does not match visible width')
end

local function emacs_key(k)
  return (k:gsub('_', '-'))
end

local function emacs_known_keys()
  local set = {}
  for _, k in ipairs(EMACS_LET_KEYS) do
    set[k] = true
  end
  return set
end

-- Module-level audit: depends only on constants, no need to repeat per variant.
local EMACS_KNOWN = emacs_known_keys()

local function emacs_check_key(key, context)
  if not EMACS_KNOWN[key] then
    error('emacs: unknown palette key "' .. tostring(key) .. '" in ' .. context)
  end
end

-- Emit one :keyword VALUE fragment. Returns nil if the attribute should be skipped.
local function emacs_attr_part(name, value)
  if value == nil then
    return nil
  end
  if name == 'fg' then
    emacs_check_key(value, 'fg')
    return ':foreground ,' .. emacs_key(value)
  elseif name == 'bg' then
    emacs_check_key(value, 'bg')
    return ':background ,' .. emacs_key(value)
  elseif name == 'bold' then
    return value and ':weight bold' or nil
  elseif name == 'italic' then
    return value and ':slant italic' or nil
  elseif name == 'underline' then
    if type(value) == 'table' then
      emacs_check_key(value.color, 'underline.color')
      return ':underline (:style ' .. value.style .. ' :color ,' .. emacs_key(value.color) .. ')'
    elseif value == true then
      return ':underline t'
    elseif value == false then
      return ':underline nil'
    end
    return nil
  elseif name == 'strike' then
    return value and ':strike-through t' or nil
  elseif name == 'extend' then
    return value and ':extend t' or nil
  elseif name == 'box' then
    if type(value) == 'table' then
      emacs_check_key(value.color, 'box.color')
      return ':box (:line-width ' .. value.line_width .. ' :color ,' .. emacs_key(value.color) .. ')'
    elseif value == true then
      return ':box t'
    end
    return nil
  elseif name == 'height' then
    return ':height ' .. tostring(value)
  end
  return nil
end

local function emacs_face_body(entry)
  if entry.literal then
    return entry.literal
  end
  local parts = {}
  for _, k in ipairs(EMACS_ATTR_ORDER) do
    local part = emacs_attr_part(k, entry[k])
    if part then
      parts[#parts + 1] = part
    end
  end
  return '(' .. table.concat(parts, ' ') .. ')'
end

local function emacs_face_line(entry)
  local name = entry[1]
  local body = emacs_face_body(entry)
  local pad_len = math.max(1, EMACS_NAME_COL - #name)
  return '   `(' .. name .. string.rep(' ', pad_len) .. '((,class ' .. body .. ')))'
end

local function emacs_section_comment(label)
  local dashes = 79 - EMACS_SECTION_PREFIX_COLS - #label - 1 -- 1 for space after label
  if dashes < 1 then
    dashes = 1
  end
  -- Each U+2500 is 3 bytes in UTF-8; slice by byte.
  return EMACS_SECTION_PREFIX .. label .. ' ' .. string.sub(EMACS_DASH_LINE, 1, dashes * 3)
end

-- Return the lines of the `(let (BINDINGS) ...)` opener through the final
-- binding (with its closing `))`). The body of the let is appended by the
-- caller.
local function emacs_let_block(p)
  -- longest hyphenated key is 'diff-add-inline' (15 chars); pad to 16 so
  -- names of the maximum length still get one space before the hex value.
  local key_col = 16
  local lines = { "(let ((class '((class color) (min-colors 89)))" }
  local n = #EMACS_LET_KEYS
  for i, key in ipairs(EMACS_LET_KEYS) do
    local ekey = emacs_key(key)
    local pad = string.rep(' ', math.max(1, key_col - #ekey))
    local suffix = (i == n) and '"))' or '")'
    lines[#lines + 1] = '      (' .. ekey .. pad .. '"' .. p[key] .. suffix
  end
  return lines
end

-- Generator-time sanity check. Errors on:
--   1. A palette key referenced in EMACS_FACES but absent from EMACS_LET_KEYS.
--   2. A palette key in EMACS_LET_KEYS that is never referenced.
--   3. A duplicate face name in EMACS_FACES.
local function emacs_audit()
  local referenced = {}
  local seen = {}
  local function check(face_name, kind, value)
    if type(value) == 'string' then
      if not EMACS_KNOWN[value] then
        error('emacs: face "' .. face_name .. '" references unknown palette key "' .. value .. '" in ' .. kind)
      end
      referenced[value] = true
    end
  end
  for _, entry in ipairs(EMACS_FACES) do
    if entry.section == nil then
      local name = entry[1]
      if not name then
        error('emacs: face entry with no name')
      end
      if seen[name] then
        error('emacs: duplicate face name "' .. name .. '"')
      end
      seen[name] = true
      check(name, 'fg', entry.fg)
      check(name, 'bg', entry.bg)
      if type(entry.underline) == 'table' then
        check(name, 'underline.color', entry.underline.color)
      end
      if type(entry.box) == 'table' then
        check(name, 'box.color', entry.box.color)
      end
    end
  end
  for _, key in ipairs(EMACS_LET_KEYS) do
    if not referenced[key] then
      error('emacs: EMACS_LET_KEYS contains unused palette key "' .. key .. '"')
    end
  end
end

emacs_audit()

local function flint_face(entry)
  if entry.section then
    return entry
  end

  local result = {}
  for key, value in pairs(entry) do
    result[key] = value
  end

  local overrides = {
    ['font-lock-builtin-face'] = { fg = 'fg1', italic = true },
    ['font-lock-function-name-face'] = { fg = 'accent', bold = true },
    ['font-lock-function-call-face'] = { fg = 'accent' },
    ['font-lock-type-face'] = { fg = 'fg1', italic = true },
    ['font-lock-constant-face'] = { fg = 'green' },
    ['font-lock-preprocessor-face'] = { fg = 'accent2' },
    ['font-lock-regexp-grouping-backslash'] = { fg = 'green' },
    ['font-lock-regexp-grouping-construct'] = { fg = 'green' },
    ['font-lock-escape-face'] = { fg = 'green' },
    ['font-lock-number-face'] = { fg = 'green' },
    ['font-lock-reference-face'] = { fg = 'fg1', italic = true },
  }
  local override = overrides[entry[1]]
  if override then
    result = { entry[1] }
    for key, value in pairs(override) do
      result[key] = value
    end
    return result
  end

  local heading = entry[1]:match('^outline%-(%d)$')
    or entry[1]:match('^org%-level%-(%d)$')
    or entry[1]:match('^markdown%-header%-face%-(%d)$')
  if heading then
    local colors = { 'accent', 'accent2', 'fg1', 'accent', 'accent2', 'fg1', 'accent', 'accent2' }
    result.fg = colors[tonumber(heading)]
  end
  return result
end

local function temper_face(entry)
  if entry.section then
    return entry
  end

  local result = {}
  for key, value in pairs(entry) do
    result[key] = value
  end

  local overrides = {
    ['font-lock-builtin-face'] = { fg = 'fg1', italic = true },
    ['font-lock-function-name-face'] = { fg = 'accent', bold = true },
    ['font-lock-function-call-face'] = { fg = 'accent' },
    ['font-lock-type-face'] = { fg = 'fg1', italic = true },
    ['font-lock-constant-face'] = { fg = 'accent', italic = true },
    ['font-lock-preprocessor-face'] = { fg = 'accent2' },
    ['font-lock-regexp-grouping-backslash'] = { fg = 'accent', italic = true },
    ['font-lock-regexp-grouping-construct'] = { fg = 'accent', italic = true },
    ['font-lock-escape-face'] = { fg = 'accent', italic = true },
    ['font-lock-number-face'] = { fg = 'accent', italic = true },
    ['font-lock-reference-face'] = { fg = 'fg1', italic = true },
    ['font-lock-string-face'] = { fg = 'accent', italic = true },
  }
  local override = overrides[entry[1]]
  if override then
    result = { entry[1] }
    for key, value in pairs(override) do
      result[key] = value
    end
    return result
  end

  local heading = entry[1]:match('^outline%-(%d)$')
    or entry[1]:match('^org%-level%-(%d)$')
    or entry[1]:match('^markdown%-header%-face%-(%d)$')
  if heading then
    local colors = { 'accent', 'accent2', 'fg1', 'accent', 'accent2', 'fg1', 'accent', 'accent2' }
    result.fg = colors[tonumber(heading)]
  end
  return result
end

local function palette_key(p, color, context)
  for _, key in ipairs(EMACS_LET_KEYS) do
    if p[key] == color then
      return key
    end
  end
  error('emacs: role "' .. context .. '" references color outside the palette: ' .. tostring(color))
end

local function role_face(name, p, role)
  local result = { name }
  if role.fg then
    result.fg = palette_key(p, role.fg, name)
  end
  for _, attribute in ipairs({ 'bold', 'italic', 'underline' }) do
    if role[attribute] ~= nil then
      result[attribute] = role[attribute]
    end
  end
  return result
end

local function profile_face(entry, p, profile)
  if entry.section then
    return entry
  end

  local result = {}
  for key, value in pairs(entry) do
    result[key] = value
  end

  local r = profile.syntax
  local overrides = {
    ['font-lock-comment-face'] = r.comment,
    ['font-lock-comment-delimiter-face'] = r.comment,
    ['font-lock-doc-face'] = r.comment,
    ['font-lock-doc-markup-face'] = r.comment,
    ['font-lock-keyword-face'] = r.control,
    ['font-lock-builtin-face'] = r.builtin,
    ['font-lock-function-name-face'] = r.definition,
    ['font-lock-function-call-face'] = r.call,
    ['font-lock-type-face'] = r.type,
    ['font-lock-constant-face'] = r.literal,
    ['font-lock-preprocessor-face'] = r.control,
    ['font-lock-regexp-grouping-backslash'] = r.literal,
    ['font-lock-regexp-grouping-construct'] = r.literal,
    ['font-lock-escape-face'] = r.literal,
    ['font-lock-number-face'] = r.literal,
    ['font-lock-reference-face'] = r.type,
    ['font-lock-string-face'] = r.literal,
    link = r.link,
    ['link-visited'] = r.link,
    ['org-link'] = r.link,
    ['org-roam-link'] = r.link,
    ['markdown-link-face'] = r.link,
    ['markdown-url-face'] = r.link,
    ['markdown-plain-url-face'] = r.link,
    ['shr-link'] = r.link,
    ['shr-visited-link'] = r.link,
  }
  local override = overrides[entry[1]]
  if override then
    return role_face(entry[1], p, override)
  end

  local heading = entry[1]:match('^outline%-(%d)$')
    or entry[1]:match('^org%-level%-(%d)$')
    or entry[1]:match('^markdown%-header%-face%-(%d)$')
  if heading then
    local index = (tonumber(heading) - 1) % #profile.headings + 1
    result.fg = palette_key(p, profile.headings[index], entry[1])
  end
  return result
end

local function gen_emacs(p, variant, appearance, profile)
  -- Fail fast if palette is missing any key the let block needs.
  for _, key in ipairs(EMACS_LET_KEYS) do
    if p[key] == nil then
      error('emacs: palette for variant "' .. variant .. '" is missing key "' .. key .. '"')
    end
  end

  local theme = appearance.slug .. '-' .. variant
  local file = theme .. '-theme.el'

  local lines = {
    ';;; ' .. file .. ' --- ' .. appearance.display_name .. ' ' .. variant .. ' color theme -*- lexical-binding: t -*-',
    '',
    ';;; Commentary:',
    ';; Generated by token colorscheme. Do not edit manually.',
    ';; Face list adapted from work by srg-dev',
    ';; (https://github.com/ThorstenRhau/token/pull/1).',
    '',
    ';;; Code:',
    '',
    '(deftheme ' .. theme .. ' "' .. appearance.display_name .. ' ' .. variant .. ' color theme.")',
    '',
  }

  extend_lines(lines, emacs_let_block(p))
  lines[#lines + 1] = ''
  lines[#lines + 1] = '  (custom-theme-set-faces'
  lines[#lines + 1] = "   '" .. theme

  local last_face_idx
  for _, entry in ipairs(EMACS_FACES) do
    if appearance.name == 'token-flint' then
      entry = flint_face(entry)
    elseif appearance.name == 'token-temper' then
      entry = temper_face(entry)
    elseif profile then
      entry = profile_face(entry, p, profile)
    end
    if entry.section then
      lines[#lines + 1] = ''
      lines[#lines + 1] = emacs_section_comment(entry.section)
    else
      lines[#lines + 1] = emacs_face_line(entry)
      last_face_idx = #lines
    end
  end
  -- Close custom-theme-set-faces and outer let on the last face line.
  lines[last_face_idx] = lines[last_face_idx] .. '))'

  lines[#lines + 1] = ''
  lines[#lines + 1] = ';;;###autoload'
  lines[#lines + 1] = '(when load-file-name'
  lines[#lines + 1] = "  (add-to-list 'custom-theme-load-path"
  lines[#lines + 1] = '               (file-name-as-directory (file-name-directory load-file-name))))'
  lines[#lines + 1] = ''
  lines[#lines + 1] = '(provide-theme ' .. "'" .. theme .. ')'
  lines[#lines + 1] = ''
  lines[#lines + 1] = ';;; ' .. file .. ' ends here'
  lines[#lines + 1] = ''

  return { path = 'contrib/emacs/' .. file, content = table.concat(lines, '\n') }
end

return gen_emacs
