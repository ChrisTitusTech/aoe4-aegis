#!/bin/bash

# Build the React app first
echo "Building React application..."
npm install
npm run build

# Copy React build output to Hugo static directory
echo "Copying React build to Hugo static directory..."
rm -rf static/react-app
mkdir -p static/react-app
cp -r build/* static/react-app/

# Extract CSS and JS references from the built index.html
echo "Extracting asset references..."
BUILD_HTML="build/index.html"

# Copy the built index.html as our Hugo template
cp "$BUILD_HTML" layouts/index.html

# Build Hugo site
echo "Building Hugo site..."
hugo --minify

# Copy everything from static/react-app to public root
echo "Finalizing build..."
cp -r static/react-app/* public/

echo "Build complete! Output is in the 'public' directory."
