#!/bin/bash

# Download Fira Sans Fonts Script
# This script downloads Fira Sans font files from the official Mozilla Fira repository

set -e

FIRA_SANS_DIR="fonts/fira-sans"
# Try multiple download URLs as GitHub redirects may vary
DOWNLOAD_URLS=(
    "https://github.com/mozilla/Fira/archive/refs/tags/4.202.zip"
    "https://github.com/mozilla/Fira/releases/download/4.202/Fira_Sans_4_202.zip"
    "https://github.com/mozilla/Fira/archive/master.zip"
)
TEMP_DIR=$(mktemp -d)

echo "📥 Downloading Fira Sans fonts..."
echo ""

# Create directory if it doesn't exist
mkdir -p "$FIRA_SANS_DIR"

# Try downloading from multiple sources
DOWNLOAD_SUCCESS=false
for DOWNLOAD_URL in "${DOWNLOAD_URLS[@]}"; do
    echo "🔗 Trying: $DOWNLOAD_URL"
    if curl -L -f -o "$TEMP_DIR/fira-sans.zip" "$DOWNLOAD_URL" 2>/dev/null; then
        echo "✅ Download completed"
        DOWNLOAD_SUCCESS=true
        break
    else
        echo "❌ Failed with this URL, trying next..."
    fi
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo "❌ Failed to download Fira Sans fonts from all sources"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo ""
echo "📦 Extracting fonts..."

# Extract the zip file to a temporary location
if ! unzip -q "$TEMP_DIR/fira-sans.zip" -d "$TEMP_DIR"; then
    echo "❌ Failed to extract zip file"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Find TTF directory (it might be in different locations depending on source)
TTF_DIR=""
if [ -d "$TEMP_DIR/Fira-4.202/ttf" ]; then
    TTF_DIR="$TEMP_DIR/Fira-4.202/ttf"
elif [ -d "$TEMP_DIR/Fira-master/ttf" ]; then
    TTF_DIR="$TEMP_DIR/Fira-master/ttf"
elif [ -d "$TEMP_DIR/Fira-4.202/TTF" ]; then
    TTF_DIR="$TEMP_DIR/Fira-4.202/TTF"
elif [ -d "$TEMP_DIR/Fira-master/TTF" ]; then
    TTF_DIR="$TEMP_DIR/Fira-master/TTF"
fi

# Find and copy TTF files to the fira-sans directory
if [ -n "$TTF_DIR" ] && [ -d "$TTF_DIR" ]; then
    cp "$TTF_DIR"/FiraSans*.ttf "$FIRA_SANS_DIR/" 2>/dev/null || true
    FONT_COUNT=$(ls "$FIRA_SANS_DIR"/FiraSans*.ttf 2>/dev/null | wc -l)
    if [ "$FONT_COUNT" -gt 0 ]; then
        echo "✅ TTF files extracted ($FONT_COUNT files)"
    fi
else
    echo "⚠️  Could not find TTF directory in extracted archive"
fi

# Find and copy OTF files if needed
OTF_DIR=""
if [ -d "$TEMP_DIR/Fira-4.202/otf" ]; then
    OTF_DIR="$TEMP_DIR/Fira-4.202/otf"
elif [ -d "$TEMP_DIR/Fira-master/otf" ]; then
    OTF_DIR="$TEMP_DIR/Fira-master/otf"
elif [ -d "$TEMP_DIR/Fira-4.202/OTF" ]; then
    OTF_DIR="$TEMP_DIR/Fira-4.202/OTF"
elif [ -d "$TEMP_DIR/Fira-master/OTF" ]; then
    OTF_DIR="$TEMP_DIR/Fira-master/OTF"
fi

if [ -n "$OTF_DIR" ] && [ -d "$OTF_DIR" ]; then
    cp "$OTF_DIR"/FiraSans*.otf "$FIRA_SANS_DIR/" 2>/dev/null || true
    OTF_COUNT=$(ls "$FIRA_SANS_DIR"/FiraSans*.otf 2>/dev/null | wc -l)
    if [ "$OTF_COUNT" -gt 0 ]; then
        echo "✅ OTF files extracted ($OTF_COUNT files)"
    fi
fi

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Fira Sans fonts successfully downloaded!"
echo "📁 Fonts location: $FIRA_SANS_DIR/"
echo ""
echo "📋 Downloaded files:"
ls -1 "$FIRA_SANS_DIR"/*.ttf 2>/dev/null | wc -l | xargs echo "   TTF files:"
ls -1 "$FIRA_SANS_DIR"/*.otf 2>/dev/null | wc -l | xargs echo "   OTF files:"
echo ""
echo "ℹ️  Next step: Run './convert_fira_sans.sh' to ligaturize the fonts"
