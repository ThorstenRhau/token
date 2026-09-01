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
then inspect the saved files directly. A safety-denied attachment is definitive;
switch to the native fallback immediately instead of retrying the attachment.

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
Validate each generated Ghostty theme as a standalone config file with:

```bash
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config \
  --config-file=/absolute/path/to/contrib/ghostty/<scheme>-<background>
```

Do not pass normal launch options such as `--config-default-files=false` or
`--theme` to `+validate-config`. Ghostty 1.3.1 accepts only `--config-file` for
this subcommand and otherwise exits with status 1 without diagnostic output.

## Capture each window

Launch a separate Ghostty instance for each background with
`open -na /Applications/Ghostty.app --args` and these arguments. Set `<grade>`
to `-15` for dark captures and `15` for light captures so MonoLisa's grade
matches the corresponding macOS appearance:

```text
--config-default-files=false
--theme=/absolute/path/to/contrib/ghostty/<scheme>-<background>
--title=<Token Appearance Background> · Neovim
--font-family=MonoLisaCode
--font-family=Symbols Nerd Font Mono
--font-size=13
--font-synthetic-style=false
--font-variation=wght=450
--font-variation=GRAD=<grade>
--font-variation-bold=wght=700
--font-variation-bold=GRAD=<grade>
--font-variation-italic=wght=450
--font-variation-italic=GRAD=<grade>
--font-variation-bold-italic=wght=700
--font-variation-bold-italic=GRAD=<grade>
--font-feature=+calt,+cv01,+cv02,+cv03,+cv04,+cv05,+cv06,-cv07,-cv08
--font-feature=+cv09,+cv10,+cv11,+cv12,+dlig,+liga,+ss01
--font-feature=-ss02,-ss03,-ss04,-ss05,-ss06,-ss07,-ss08
--font-feature=-ss09,-ss10,-ss11,-ss12,+ss13,-ss14,-ss15,-zero
--window-title-font-family=MonoLisaText
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
3. Poll `CGWindowListCopyWindowInfo` for that PID's layer-zero window until it
   returns a positive window number. The process may exist briefly before its
   window is available.
4. Capture it at native Retina resolution with
   `/usr/sbin/screencapture -l<window-id> -x -t png <output>`.
5. Terminate only the new capture process, using a `finally` path so a failed
   lookup or capture cannot leave the isolated Ghostty instance running.
6. Name the outputs `<scheme>-dark.png` and `<scheme>-light.png`.

When parsing a window number in JavaScript, trim the command output and reject
an empty string before calling `Number(...)`: `Number('')` is `0`, and passing
`-l0` makes `screencapture` fail with `could not create image from window`.
Treat zero, non-integers, and missing output as "not ready" and keep polling.
For example:

```js
const raw = stdout.trim()
const windowId = raw === '' ? undefined : Number(raw)
return Number.isInteger(windowId) && windowId > 0 ? windowId : undefined
```

In a persistent `node_repl`, replace or call the intended helper explicitly;
reassigning a global property does not replace an earlier top-level `const`
binding with the same name.

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

- Native Retina resolution without resizing, identical dimensions for the dark
  and light captures, and 8-bit RGBA
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
