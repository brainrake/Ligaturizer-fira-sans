#!/bin/bash
# Liga Fira Sans Font Generation Script
# This script converts Fira Sans fonts to Liga Fira Sans with proportional ligatures from Fira Code

echo "🔄 Starting Liga Fira Sans font generation..."
echo "📁 Using fonts from: fonts/fira-sans/"
echo "💾 Output directory: fonts/output/"
echo ""

# Check if FontForge is available
if ! command -v fontforge &> /dev/null; then
    echo "❌ FontForge is not available. Using nix shell..."
    FONTFORGE_CMD="nix shell nixpkgs#fontforge --command fontforge"
else
    FONTFORGE_CMD="fontforge"
fi

echo "🔧 FontForge command: $FONTFORGE_CMD"
echo ""

# Define font weights to process
declare -a FONTS=(
    "Regular:fonts/fira-sans/FiraSans-Regular.ttf"
    "Bold:fonts/fira-sans/FiraSans-Bold.ttf"
    "Medium:fonts/fira-sans/FiraSans-Medium.ttf"
)

# Process each font weight using a loop
for font_spec in "${FONTS[@]}"; do
    # Split weight and font path
    WEIGHT="${font_spec%%:*}"
    FONT_PATH="${font_spec##*:}"
    
    echo "⚡ Generating Liga Fira Sans ${WEIGHT}..."
    $FONTFORGE_CMD -lang py -script ligaturize.py \
        "$FONT_PATH" \
        --output-dir=fonts/output/ \
        --output-name='Fira Sans' \
        --prefix="Liga" \
        --copy-character-glyphs

    if [ $? -eq 0 ]; then
        echo "✅ Liga Fira Sans ${WEIGHT} generated successfully!"
    else
        echo "❌ Failed to generate Liga Fira Sans ${WEIGHT}"
        exit 1
    fi

    echo ""
done

echo ""
echo "🎉 All Liga Fira Sans fonts generated successfully!"
echo ""
echo "📋 Generated files:"
echo "   • fonts/output/LigaFiraSans-Regular.ttf"
echo "   • fonts/output/LigaFiraSans-Bold.ttf"
echo "   • fonts/output/LigaFiraSans-Medium.ttf"
echo ""
echo "🌐 Test the fonts by opening: liga_fira_sans_test.html"
echo ""
echo "ℹ️  These fonts feature proportional programming ligatures that integrate"
echo "   seamlessly with Fira Sans' natural spacing rhythm!"
