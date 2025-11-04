#!/bin/bash
# Generate keymap visualizations locally
# Outputs: YAML, SVG, PNG, and PDF files to keymap-drawer/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to repository root
cd "$(dirname "$0")/.."

echo "🗺️  ZMK Keymap Generator"
echo "======================"
echo ""

# Check for dependencies
echo "Checking dependencies..."
MISSING_DEPS=()

if ! command -v keymap &> /dev/null; then
    MISSING_DEPS+=("keymap-drawer")
fi

if ! command -v west &> /dev/null; then
    MISSING_DEPS+=("west")
fi

if ! command -v inkscape &> /dev/null; then
    MISSING_DEPS+=("inkscape")
fi

# Report missing dependencies
if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${RED}✗ Missing dependencies:${NC} ${MISSING_DEPS[*]}"
    echo ""
    echo "Install missing dependencies:"

    for dep in "${MISSING_DEPS[@]}"; do
        case $dep in
            keymap-drawer)
                echo "  $ pipx install keymap-drawer"
                ;;
            west)
                echo "  $ pipx install west"
                ;;
            inkscape)
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    echo "  $ brew install inkscape"
                elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    echo "  $ sudo apt-get install inkscape"
                else
                    echo "  Visit: https://inkscape.org/release/"
                fi
                ;;
        esac
    done

    exit 1
fi

echo -e "${GREEN}✓${NC} All dependencies found"
echo ""

# Fetch west modules if needed
if [ ! -d ".west" ]; then
    echo "Initializing west workspace..."
    west init -l config
    west config --local manifest.project-filter " -zmk,-zephyr"
fi

if [ ! -d "zmk" ]; then
    echo "Fetching ZMK modules (this may take a moment)..."
    west update --fetch-opt=--filter=tree:0
    echo -e "${GREEN}✓${NC} ZMK modules fetched"
    echo ""
fi

# Create output directory
mkdir -p keymap-drawer

# Check for config file
config_arg=""
if [ -f "keymap_drawer.config.yaml" ]; then
    config_arg="-c keymap_drawer.config.yaml"
    echo "Using config: keymap_drawer.config.yaml"
fi

echo ""
echo "Generating keymap diagrams..."
echo ""

# Process each keymap file
for keymap_file in config/*.keymap; do
    if [ ! -f "$keymap_file" ]; then
        echo -e "${YELLOW}⚠${NC} No keymap files found in config/"
        exit 1
    fi

    keyboard=$(basename -s .keymap "$keymap_file")
    echo "📋 Processing: $keyboard"

    # Parse keymap to YAML
    echo "  → Generating YAML..."
    keymap $config_arg parse -z "$keymap_file" > "keymap-drawer/${keyboard}.yaml"

    # Draw SVG
    echo "  → Generating SVG..."
    keymap $config_arg draw "keymap-drawer/${keyboard}.yaml" > "keymap-drawer/${keyboard}.svg"

    # Convert SVG to PNG
    echo "  → Generating PNG..."
    inkscape --export-type=png \
        --export-dpi=300 \
        "keymap-drawer/${keyboard}.svg" \
        -o "keymap-drawer/${keyboard}.png" 2>/dev/null

    # Convert SVG to PDF
    echo "  → Generating PDF..."
    inkscape --export-type=pdf \
        "keymap-drawer/${keyboard}.svg" \
        -o "keymap-drawer/${keyboard}.pdf" 2>/dev/null

    echo -e "  ${GREEN}✓${NC} Generated ${keyboard}.{yaml,svg,png,pdf}"
    echo ""
done

echo -e "${GREEN}✅ All keymap diagrams generated successfully!${NC}"
echo ""
echo "Output files:"
ls -lh keymap-drawer/
