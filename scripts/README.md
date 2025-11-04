# ZMK Config Scripts

This directory contains utility scripts for working with the ZMK configuration locally.

## generate-keymap.sh

Generates keymap visualizations locally without needing GitHub Actions.

### Prerequisites

Install the required tools:

```bash
# Install keymap-drawer and west
pipx install keymap-drawer
pipx install west

# Install Inkscape
# macOS:
brew install inkscape

# Linux (Debian/Ubuntu):
sudo apt-get install inkscape
```

### Usage

Run the script from anywhere in the repository:

```bash
./scripts/generate-keymap.sh
```

Or make it executable and run directly:

```bash
chmod +x scripts/generate-keymap.sh
./scripts/generate-keymap.sh
```

### Output

The script generates the following files in `keymap-drawer/`:
- `*.yaml` - Parsed keymap data
- `*.svg` - Scalable vector graphic (used in releases)
- `*.png` - High-resolution raster image (300 DPI)
- `*.pdf` - Printable document (used in releases)

### How It Works

1. Checks for required dependencies (keymap-drawer, west, inkscape)
2. Initializes west workspace if needed
3. Fetches ZMK modules if not already present
4. Parses each `.keymap` file in `config/` to YAML
5. Generates SVG from YAML using keymap-drawer
6. Converts SVG to PNG and PDF using Inkscape

### Configuration

The script uses `keymap_drawer.config.yaml` if present in the repository root to customize the appearance of generated diagrams.

### Troubleshooting

**"Command not found" errors:**
- Ensure `pipx` is installed: `python3 -m pip install --user pipx`
- Ensure pipx binaries are in your PATH
- Run `pipx ensurepath` and restart your shell

**"No keymap files found":**
- Ensure you're running from the repository root or scripts directory
- Check that `config/*.keymap` files exist

**Inkscape errors:**
- Ensure Inkscape is properly installed and in your PATH
- Try running `inkscape --version` to verify
