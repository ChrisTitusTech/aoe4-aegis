# Integrating Aegis into an Existing Hugo Website

This guide explains how to add the Aegis game as a single page within your existing Hugo site.

## Option 1: As a Hugo Page (Recommended)

### Step 1: Build the React App

```bash
npm install
npm run build
```

This creates a `build/` directory with all compiled assets.

### Step 2: Copy Assets to Your Hugo Site

Copy the built files to your Hugo site:

```bash
# Assuming your Hugo site is at ~/my-hugo-site/
HUGO_SITE="~/my-hugo-site"

# Copy JS and CSS assets to Hugo's static directory
cp -r build/static/* $HUGO_SITE/static/aegis-assets/

# Copy other static files (images, manifest, etc)
cp build/manifest.json $HUGO_SITE/static/aegis-assets/
cp build/robots.txt $HUGO_SITE/static/aegis-assets/
```

### Step 3: Create a Hugo Content Page

Create `$HUGO_SITE/content/aegis.md`:

```markdown
---
title: "Aegis - AoE4 Building Practice"
date: 2024-01-01
layout: "aegis"
type: "page"
---

Practice your Age of Empires IV building shortcuts with this interactive game.
```

### Step 4: Create a Hugo Layout Template

Create `$HUGO_SITE/layouts/page/aegis.html`:

```html
{{ define "main" }}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Practice Age of Empires IV building shortcuts" />
    <title>{{ .Title }} | {{ .Site.Title }}</title>
    
    <!-- React App CSS - Update these paths based on your build output -->
    <link href="/aegis-assets/css/main.css" rel="stylesheet">
</head>
<body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
    
    <!-- React App JS - Update these paths based on your build output -->
    <script src="/aegis-assets/js/main.js"></script>
</body>
</html>
{{ end }}
```

### Step 5: Extract Correct Asset Paths

After building, check `build/index.html` to get the exact filenames (they include hashes):

```bash
cat build/index.html
```

You'll see lines like:
- `/static/css/main.abc123.css`
- `/static/js/main.xyz789.js`

Update the layout template with these exact paths.

---

## Option 2: As an iframe (Simpler, but less integrated)

If you want to keep it completely separate:

### Step 1: Deploy React App to Subdomain

1. Deploy the React app to a subdomain (e.g., `aegis.yoursite.com`)
2. Use the standalone Cloudflare Pages setup from the main README

### Step 2: Embed in Hugo Page

Create a Hugo content page that embeds it:

```markdown
---
title: "Aegis Game"
---

<iframe 
    src="https://aegis.yoursite.com" 
    style="width: 100%; height: 100vh; border: none;"
    title="Aegis - AoE4 Building Practice">
</iframe>
```

---

## Option 3: Automated Integration Script

Here's a script to automate copying to your Hugo site:

```bash
#!/bin/bash

HUGO_SITE_PATH="$1"

if [ -z "$HUGO_SITE_PATH" ]; then
    echo "Usage: ./integrate-to-hugo.sh /path/to/hugo-site"
    exit 1
fi

# Build React app
npm install
npm run build

# Create directories
mkdir -p "$HUGO_SITE_PATH/static/aegis"
mkdir -p "$HUGO_SITE_PATH/layouts/page"
mkdir -p "$HUGO_SITE_PATH/content"

# Copy assets
cp -r build/static/* "$HUGO_SITE_PATH/static/aegis/"
cp build/manifest.json "$HUGO_SITE_PATH/static/aegis/"

# Extract asset paths from build
CSS_FILE=$(grep -o 'href="[^"]*\.css"' build/index.html | head -1 | sed 's/href="//;s/"//')
JS_FILE=$(grep -o 'src="[^"]*\.js"' build/index.html | grep -v 'type="module"' | head -1 | sed 's/src="//;s/"//')

# Create layout
cat > "$HUGO_SITE_PATH/layouts/page/aegis.html" << 'EOF'
{{ define "main" }}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>{{ .Title }}</title>
    <link href="/aegis/css/main.css" rel="stylesheet">
</head>
<body>
    <div id="root"></div>
    <script src="/aegis/js/main.js"></script>
</body>
</html>
{{ end }}
EOF

# Create content page if it doesn't exist
if [ ! -f "$HUGO_SITE_PATH/content/aegis.md" ]; then
    cat > "$HUGO_SITE_PATH/content/aegis.md" << 'EOF'
---
title: "Aegis - AoE4 Building Practice"
layout: "aegis"
type: "page"
---
EOF
fi

echo "✅ Integration complete!"
echo "📁 Assets copied to: $HUGO_SITE_PATH/static/aegis/"
echo "📄 Layout created at: $HUGO_SITE_PATH/layouts/page/aegis.html"
echo "📝 Content page at: $HUGO_SITE_PATH/content/aegis.md"
echo ""
echo "Next steps:"
echo "1. Build your Hugo site: cd $HUGO_SITE_PATH && hugo"
echo "2. Your game will be available at /aegis/"
```

Save as `integrate-to-hugo.sh` and use:

```bash
chmod +x integrate-to-hugo.sh
./integrate-to-hugo.sh /path/to/your/hugo-site
```

---

## Handling Asset Paths

React apps use hashed filenames (e.g., `main.abc123.js`). Two options:

### Option A: Manual Update
After each build, check `build/index.html` and update the Hugo layout with new paths.

### Option B: Use PUBLIC_URL
In your `.env` file:
```
PUBLIC_URL=/aegis
```

Then rebuild, and all assets will reference `/aegis/static/...`

---

## Best Practices

1. **Namespace assets**: Keep all React assets in `/static/aegis/` to avoid conflicts
2. **Cache busting**: Hugo handles this automatically with hashed filenames
3. **Testing**: Test the integration locally with `hugo server` before deploying
4. **Updates**: When updating the React app, rebuild and re-copy assets

---

## Troubleshooting

### Assets not loading
- Check browser console for 404 errors
- Verify paths in the Hugo layout match the built files
- Ensure assets are in Hugo's `static/` directory

### Styling conflicts
- The React app has isolated styles, but check for CSS conflicts
- Consider wrapping in an iframe if conflicts occur

### JavaScript errors
- Ensure React app is built for production (`npm run build`)
- Check that all dependencies are bundled correctly
