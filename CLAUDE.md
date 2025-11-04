# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a ZMK firmware configuration for the Allium58 keyboard (a Lily58 variant). The keyboard is a split ergonomic keyboard using nice!nano v2 controllers with nice!view displays. ZMK is a modern wireless keyboard firmware built on Zephyr RTOS.

## Build System

Firmware builds are automated via GitHub Actions - there is no local build process. The ZMK team provides a reusable workflow that compiles the firmware in the cloud.

**Build workflow:** `.github/workflows/build.yml` triggers on push/PR and uses ZMK's official build workflow.

**Important:** Never attempt to build locally. ZMK firmware must be built through the GitHub Actions workflow.

## Keymap Development

### File Structure

- `config/lily58.keymap` - Main firmware keymap written in ZMK devicetree syntax (`.keymap` files use C preprocessor and devicetree bindings)
- `config/lily58.conf` - Keyboard configuration options (enables display, studio mode, pointing device support, high BT power)
- `keymap_drawer.config.yaml` - Visual styling for generated diagrams (dark mode, dimensions, etc.)
- `keymap-drawer/` - **Auto-generated directory** containing visualization outputs (SVG, YAML, PDF). Never edit these files manually.

**When modifying keymaps:**
1. Edit `config/lily58.keymap` for firmware changes
2. Commit and push - the GitHub Actions workflow will automatically regenerate visualizations
3. Never manually edit files in `keymap-drawer/` - they are regenerated from the `.keymap` file

### Layer Architecture

The firmware defines 6 layers (0-indexed):
- **0 (default_layer):** QWERTY with home row mods using urob-style timerless timing
- **1 (lower_layer):** Symbols and F-keys
- **2 (raise_layer):** Navigation, tmux shortcuts, and window tiling macros
- **3 (adjust_layer):** Bluetooth and system controls (activated via conditional layer when both 1+2 held)
- **4 (extra):** Mouse movement and scrolling (experimental pointing device support)
- **5 (gaming):** Gaming layer without home row mods (toggled from adjust layer)

### Home Row Mods

The keymap uses timerless/urob-style home row mods with separate behaviors for left and right hands:
- Left: `bhv_hrm_left` - Ctrl, Alt, Cmd, Shift (C-A-G-S in ZMK terminology)
- Right: `bhv_hrm_right` - Shift, Cmd, Alt, Ctrl (S-G-A-C)
- Timing: 280ms tapping-term, 175ms quick-tap, 150ms require-prior-idle
- `hold-trigger-key-positions` defines opposite hand keys to enable proper cross-hand holds

See config/lily58.keymap:23-49 for implementation details.

### Macros

Custom macros for productivity (config/lily58.keymap:62-98):
- `tmux_prefix` - Sends Ctrl+B
- `tile_left`, `tile_right`, `tile_max` - macOS window management (Ctrl+Opt+Arrow/F)

### Safety Features

**Bluetooth Clear Combo:** BT_CLR_ALL is protected by a combo requiring simultaneous press of two keys on the adjust layer (positions 1+2). This prevents accidental clearing of all Bluetooth pairings. See config/lily58.keymap:100-110.

## Keymap Visualization

### Automatic (GitHub Actions)

The `draw-keymaps.yml` workflow runs after successful builds:
1. Parses `config/*.keymap` files using keymap-drawer
2. Generates SVG, YAML, and PDF visualizations in `keymap-drawer/`
3. Auto-commits SVG/YAML to repo with "[skip ci]" message
4. Uploads PDF as artifact for release workflow

**Never manually edit files in keymap-drawer/** - they are automatically regenerated from the source `.keymap` files.

### Local Generation

Run `./scripts/generate-keymap.sh` to generate visualizations locally (useful for previewing changes before pushing).

**Prerequisites:**
```bash
pipx install keymap-drawer west
brew install inkscape  # macOS
```

**Outputs:** Creates `keymap-drawer/*.{yaml,svg,png,pdf}` from all `.keymap` files in `config/`

**Note:** Local generation produces PNG files (not created by GitHub Actions). Do not commit PNG files.

## Release Process

The `release.yml` workflow creates GitHub releases automatically:
1. Triggers after successful keymap drawing workflow (which requires successful build)
2. Downloads firmware `.uf2` files from build workflow artifacts
3. Downloads keymap PDF from draw-keymaps workflow artifacts
4. Bundles everything into a zip with tag suffix
5. Creates release with auto-generated tag format: `vYYYYMMDD.{commit_count}`
6. Includes comprehensive flashing instructions in release notes

**Release contents:**
- `allium58-firmware-bundle-{tag}.zip` - Complete package (left/right firmware, settings reset, keymap PDF)
- `lily58.pdf` - Standalone keymap reference
- `lily58.svg` - Standalone keymap diagram

**Adding custom docs to releases:** Edit release.yml:82-104 to copy additional files to `release-assets/`

## Hardware Configuration

**Build matrix** (`build.yaml`):
- Left half: lily58_left + nice_view_adapter + nice_view with studio-rpc-usb-uart snippet
- Right half: lily58_right + nice_view_adapter + nice_view
- Settings reset: For clearing NVRAM when needed

**Controller:** nice!nano v2 (nRF52840-based)

**Display:** nice!view (memory LCD) via adapter shield

**Bluetooth:** High power mode enabled (+8dBm) for better range - comment out `CONFIG_BT_CTLR_TX_PWR_PLUS_8=y` in lily58.conf to reduce battery drain

## West/Zephyr

`config/west.yml` defines the manifest importing ZMK's main branch. The `self: path: config` line tells west that this repo's config files are in the `config/` directory.

**Note:** West is only needed for local keymap visualization (to parse devicetree), not for firmware building.

## Important Configuration Flags

In `config/lily58.conf`:
- `CONFIG_ZMK_DISPLAY=y` - Enables nice!view
- `CONFIG_ZMK_KEYBOARD_NAME="Allium58"` - Bluetooth device name
- `CONFIG_ZMK_STUDIO=y` - Enables ZMK Studio for live keymap editing
- `CONFIG_ZMK_SLEEP=y` - Battery saving sleep mode
- `CONFIG_ZMK_POINTING=y` - Experimental pointing device support (mouse layer)

## Common Workflow

1. Edit `config/lily58.keymap` to change firmware behavior
2. Optionally run `./scripts/generate-keymap.sh` to preview visualizations locally
3. Commit and push to trigger build
4. Wait for build → draw-keymaps → release workflows to complete
5. Download firmware bundle from releases page
6. The workflows will automatically update `keymap-drawer/` files and commit them back to the repo

## Resources

- Shop: keyboard-hoarders.com or keyboardhoarders.etsy.com
- ZMK Documentation: https://zmk.dev/docs
- Keymap drawer: https://github.com/caksoylar/keymap-drawer
