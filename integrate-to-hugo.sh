#!/bin/bash

# Script to integrate Aegis React app into an existing Hugo site
# Usage: ./integrate-to-hugo.sh /path/to/hugo-site [page-name]

HUGO_SITE_PATH="$1"
PAGE_NAME="${2:-aegis}"

if [ -z "$HUGO_SITE_PATH" ]; then
    echo "❌ Error: Hugo site path required"
    echo "Usage: ./integrate-to-hugo.sh /path/to/hugo-site [page-name]"
    echo ""
    echo "Example:"
    echo "  ./integrate-to-hugo.sh ~/my-hugo-site aegis"
    exit 1
fi

if [ ! -d "$HUGO_SITE_PATH" ]; then
    echo "❌ Error: Hugo site directory not found: $HUGO_SITE_PATH"
    exit 1
fi

echo "🚀 Starting integration of Aegis into Hugo site..."
echo "📂 Hugo site: $HUGO_SITE_PATH"
echo "📄 Page name: $PAGE_NAME"
echo ""

# Check for npm
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed or not in PATH"
    echo ""
    echo "Please install Node.js and npm first:"
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS detected - use Homebrew:"
        echo "    brew install node"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  Linux detected - use your package manager:"
        echo "    Ubuntu/Debian: sudo apt install nodejs npm"
        echo "    Fedora: sudo dnf install nodejs npm"
        echo "    Arch: sudo pacman -S nodejs npm"
    fi
    
    echo ""
    echo "Or if using nvm, ensure it's loaded:"
    echo "  source ~/.nvm/nvm.sh"
    exit 1
fi

# Build React app
echo "📦 Building React application..."
npm install --silent
npm run build

if [ ! -d "build" ]; then
    echo "❌ Error: Build directory not found. Build may have failed."
    exit 1
fi

# Create directories in Hugo site
echo "📁 Creating directories..."
mkdir -p "$HUGO_SITE_PATH/static/$PAGE_NAME"
mkdir -p "$HUGO_SITE_PATH/layouts/page"
mkdir -p "$HUGO_SITE_PATH/content"

# Copy all assets
echo "📋 Copying assets..."
cp -r build/static/* "$HUGO_SITE_PATH/static/$PAGE_NAME/" 2>/dev/null || true
cp build/manifest.json "$HUGO_SITE_PATH/static/$PAGE_NAME/" 2>/dev/null || true
cp -r build/*.png "$HUGO_SITE_PATH/static/$PAGE_NAME/" 2>/dev/null || true

# Extract asset filenames from build/index.html
echo "🔍 Extracting asset paths..."
CSS_FILES=$(grep -o '"/static/css/[^"]*\.css"' build/index.html | sed 's/"//g' | sed 's|/static|/'"$PAGE_NAME"'|g')
JS_FILES=$(grep -o '"/static/js/[^"]*\.js"' build/index.html | sed 's/"//g' | sed 's|/static|/'"$PAGE_NAME"'|g')

# Create Hugo layout with actual asset paths
echo "🎨 Creating Hugo layout..."
cat > "$HUGO_SITE_PATH/layouts/page/$PAGE_NAME.html" << EOF
{{ define "main" }}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Practice Age of Empires IV building shortcuts" />
    <title>{{ .Title }} | {{ .Site.Title }}</title>
    <link rel="manifest" href="/$PAGE_NAME/manifest.json" />
    
    <!-- React App Styles -->
$(echo "$CSS_FILES" | while read -r css; do echo "    <link href=\"$css\" rel=\"stylesheet\" />"; done)
</head>
<body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
    
    <!-- React App Scripts -->
$(echo "$JS_FILES" | while read -r js; do echo "    <script src=\"$js\"></script>"; done)
</body>
</html>
{{ end }}
EOF

# Create content page if it doesn't exist
if [ ! -f "$HUGO_SITE_PATH/content/$PAGE_NAME.md" ]; then
    echo "📝 Creating content page..."
    cat > "$HUGO_SITE_PATH/content/$PAGE_NAME.md" << EOF
---
title: "Aegis - AoE4 Building Practice"
date: $(date +%Y-%m-%d)
layout: "$PAGE_NAME"
type: "page"
description: "Practice your Age of Empires IV building shortcuts with this interactive game"
---

A tiny game to practice Age of Empires IV building shortcuts.
EOF
else
    echo "ℹ️  Content page already exists, skipping creation"
fi

echo ""
echo "✅ Integration complete!"
echo ""
echo "📦 What was done:"
echo "   • Built React app"
echo "   • Copied assets to: $HUGO_SITE_PATH/static/$PAGE_NAME/"
echo "   • Created layout: $HUGO_SITE_PATH/layouts/page/$PAGE_NAME.html"
echo "   • Created content: $HUGO_SITE_PATH/content/$PAGE_NAME.md"
echo ""
echo "🧪 Testing locally..."
cd "$HUGO_SITE_PATH"

# Kill any existing Hugo server on port 1313
lsof -ti:1313 | xargs kill -9 2>/dev/null || true

echo "🚀 Starting Hugo development server..."
hugo server -D &
HUGO_PID=$!

# Wait for server to start
sleep 3

echo ""
echo "✨ Hugo server running!"
echo "📍 View your integrated page at: http://localhost:1313/$PAGE_NAME/"
echo ""
echo "Press Ctrl+C to stop the server and complete integration"
echo ""

# Wait for user to stop the server
wait $HUGO_PID

echo ""
echo "🎯 Integration testing complete!"
echo "🌐 In production, the page will be at: yoursite.com/$PAGE_NAME/"
