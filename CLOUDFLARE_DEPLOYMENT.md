# Aegis - Cloudflare Pages Deployment Guide

## Quick Setup

### Prerequisites
- A Cloudflare account
- This repository connected to GitHub

### Deployment Steps

1. **Go to Cloudflare Dashboard**
   - Navigate to Pages section
   - Click "Create a project"
   - Select "Connect to Git"

2. **Connect Repository**
   - Choose this repository: `aoe4-aegis`
   - Click "Begin setup"

3. **Configure Build Settings**
   ```
   Framework preset: None
   Build command: ./build-hugo.sh
   Build output directory: public
   Root directory: /
   ```

4. **Set Environment Variables**
   Add these in the "Environment variables" section:
   ```
   NODE_VERSION = 18
   HUGO_VERSION = 0.121.0
   ```

5. **Deploy**
   - Click "Save and Deploy"
   - Cloudflare will build and deploy your site

## Build Process

The `build-hugo.sh` script handles the entire build:
1. Installs npm dependencies
2. Builds the React app
3. Copies React build to Hugo static directory
4. Runs Hugo to generate final site
5. Outputs to `public/` directory

## Local Testing

Test the Hugo build locally:
```bash
# Install Hugo if not already installed
brew install hugo  # macOS
# or download from https://gohugo.io/installation/

# Run the build
npm run build:hugo

# Serve the built site locally
cd public && python3 -m http.server 8000
```

## Troubleshooting

### Build fails on Cloudflare
- Verify environment variables are set correctly
- Check that Hugo version is compatible (>= 0.121.0)
- Ensure build script has execute permissions (already set in repo)

### React app doesn't load
- Check that all assets are being copied correctly
- Verify the build output in Cloudflare Pages build logs
- Ensure `public/` directory contains index.html and all assets

## Custom Domain

To add a custom domain:
1. Go to your Cloudflare Pages project
2. Click "Custom domains"
3. Add your domain
4. Update DNS records as instructed

## Performance

Cloudflare Pages provides:
- Global CDN distribution
- Automatic HTTPS
- HTTP/3 support
- Unlimited bandwidth
- Fast builds and deployments
