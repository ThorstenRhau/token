---
name: create-theme-screenshots
description:
  Create matching dark and light PNG screenshots of Token appearances in real
  Neovim and Ghostty windows. Use when adding or refreshing README gallery
  images, capturing a newly registered Token appearance, or reproducing the
  established Token screenshot framing and color-management workflow.
---

# Create Token Theme Screenshots

Create only the requested appearance/background pairs. Capture real Ghostty and
Neovim windows; do not synthesize, resize, or generatively alter screenshots.

## Establish scope

1. Read `AGENTS.md`, `lua/token/appearance.lua`, the selected palette and
   appearance modules, and the matching files under `colors/` and
   `contrib/ghostty/`.
2. Confirm the colorscheme name and Ghostty slugs. For a scheme named
   `<scheme>`, expect `contrib/ghostty/<scheme>-dark` and
   `contrib/ghostty/<scheme>-light`.
3. Inspect the destination before writing. Preserve unrelated files and replace
   existing PNGs only when the user requested that exact output.
4. Record `git status --short --branch`. Do not edit the repository, upload
   images, update `README.md`, commit, or push unless separately requested.

## Prepare isolated fixtures

Use the Computer Use skill because the task operates real macOS applications.
Perform application launch and capture actions through `node_repl`. If Computer
Use cannot attach to Ghostty, invoke native macOS commands from `node_repl`,
then inspect the saved files directly.

Copy `assets/signal_garden.lua` and `assets/init.lua` into a disposable
`.capture/` directory under the requested output directory. Set these
environment variables for each Neovim launch:

- `TOKEN_CAPTURE_REPO`: absolute Token checkout path
- `TOKEN_CAPTURE_SCHEME`: colorscheme name such as `token-ultra`
- `TOKEN_CAPTURE_BACKGROUND`: `dark` or `light`

Run both fixtures with `nvim --clean`. Keep state isolated with
`shadafile=NONE`; do not load the user's Neovim configuration, compiled Token
cache, LSP clients, or unrelated plugins.

Before opening the GUI, validate both backgrounds headlessly. Assert
`vim.g.colors_name`, `vim.o.background`, and a resolved `Normal` background.
Validate each Ghostty file with:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config \
  --config-default-files=false \
  --theme=/absolute/path/to/contrib/ghostty/<scheme>-<background>
```

## Capture each window

Launch a separate Ghostty instance for each background with
`open -na /Applications/Ghostty.app --args` and these arguments:

```text
--config-default-files=false
--theme=/absolute/path/to/contrib/ghostty/<scheme>-<background>
--title=<Token Appearance Background> · Neovim
--font-family=Berkeley Mono Variable
--font-size=14
--window-width=96
--window-height=35
--window-save-state=never
--window-padding-x=14
--window-padding-y=14
--window-padding-balance=true
--background-opacity=1
--window-colorspace=srgb
--macos-titlebar-style=transparent
--shell-integration=none
--cursor-style=block
--cursor-style-blink=false
```

Pass Neovim as one quoted Ghostty `--initial-command=direct:...`; passing it as
separate Launch Services arguments creates unwanted tabs. Use:

```text
/usr/bin/env TOKEN_CAPTURE_REPO=<repo> TOKEN_CAPTURE_SCHEME=<scheme> \
TOKEN_CAPTURE_BACKGROUND=<background> /opt/homebrew/bin/nvim --clean \
-u <destination>/.capture/init.lua <destination>/.capture/signal_garden.lua
```

For each capture:

1. Snapshot matching Ghostty PIDs before launch.
2. Launch and identify the single new PID. Never terminate an existing
   user-owned Ghostty process.
3. Find that PID's layer-zero window with `CGWindowListCopyWindowInfo`.
4. Capture it at native Retina resolution with
   `/usr/sbin/screencapture -l<window-id> -x -t png <output>`.
5. Terminate only the new capture process.
6. Name the outputs `<scheme>-dark.png` and `<scheme>-light.png`.

## Convert to standard sRGB

Native macOS captures may contain a display-specific ICC profile plus EXIF and
ancillary chunks. Perform a color-managed conversion; do not merely remove the
profile and do not use `-normalize`, which changes the intended palette.

Generate a temporary replacement with ImageMagick:

```bash
magick <capture.png> \
  -profile '/System/Library/ColorSync/Profiles/sRGB Profile.icc' \
  -define png:color-type=6 \
  -define png:exclude-chunk=date,time,pHYs,bKGD,tEXt,zTXt,iTXt,eXIf,cICP \
  <temporary.png>
```

Validate the temporary file before replacing the native capture. Retain the
alpha channel because it contains the rounded corners and native window shadow.

## Validate and clean up

Require all of the following for every final PNG:

- `1992x1590`, 8-bit RGBA for the established 96×35 Retina setup
- `sRGB IEC61966-2.1`, with `IHDR`, `sRGB`, `gAMA`, `IDAT`, and `IEND` as the
  only PNG chunk types
- Alpha unchanged pixel-for-pixel by the color conversion
- The titlebar and editor background pixels resolve to the same color
- Correct window title and statusline appearance/background labels
- All 35 source lines visible without wrapping
- Identical cursor position at `23:9`
- No notifications, private paths, unrelated tabs, or configuration artifacts
  visible

Inspect the dark and light files visually side by side. Leave only the requested
final PNGs in the destination. Move disposable fixtures and rejected drafts to
Trash so cleanup remains recoverable. Confirm that no capture Ghostty process
remains and that repository status is unchanged.
