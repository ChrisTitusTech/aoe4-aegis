# Aegis

A tiny game to practice [Age of Empires IV](https://www.ageofempires.com/games/age-of-empires-iv/) building shortcuts.
Using ⚛️ [Create-React-App](https://reactjs.org/docs/create-a-new-react-app.html) and 🐻 [Zustand](https://github.com/pmndrs/zustand).

## Deployment

This project is configured to deploy on **Cloudflare Pages** using Hugo as the deployment framework.

### Local Development

```bash
# Install dependencies
npm install

# Run development server (React only)
npm start

# Build for production (Hugo + React)
npm run build:hugo
```

### Cloudflare Pages Setup

1. Connect your GitHub repository to Cloudflare Pages
2. Configure the build settings:
   - **Build command**: `./build-hugo.sh`
   - **Build output directory**: `public`
   - **Environment variables**:
     - `NODE_VERSION`: `18`
     - `HUGO_VERSION`: `0.121.0` (or latest)

The build process:
1. Builds the React application using Create React App
2. Copies the build output to Hugo's static directory
3. Runs Hugo to generate the final static site
4. Outputs everything to the `public` directory

### Requirements

- Node.js 18 or higher
- Hugo 0.121.0 or higher

# License

With the exception of all visual assets (`/public/buildings/*.png`), the project is licensed under MIT.
See [LICENSE](LICENSE).

# Disclaimer

Age of Empires IV © Microsoft Corporation.

This project was created under Microsoft's ["Game Content Usage Rules"](https://www.xbox.com/en-US/developers/rules) using assets from Age of Empires IV, and it is not endorsed by or affiliated with Microsoft.
