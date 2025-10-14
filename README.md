# Svelte Caddy DevOps

A lightweight **Svelte SPA** template featuring an automated **CI/CD pipeline** using **GitHub Actions** and **GHCR**, with a production-ready **Caddy** setup for **VPS** deployment.

## Architecture

```bash
.
├── .github/workflows/       # GitHub Actions (CI/CD)
│   ├── ci.yaml              # Builds & pushes your image to GHCR
│   └── cd.yaml              # Deploys automatically to your VPS
├── Makefile                
└── svelte/                  # Your Svelte app
    ├── Dockerfile           # Multi-stage build (dev / build / prod)
    ├── Caddyfile.preview    # Caddy config for local HTTP preview
    ├── Caddyfile.prod       # Caddy config for production with HTTPS
    └── [...]                # Usual Svelte tree
```

## Usage

### Step 1 - Initialize your repository

Create your repository from this template, and make sure to check `Include all branches` during creation.
This ensures you get both the main and prod branches used for CI/CD.

Once created, go to the **Actions tab** — you should see something like:

| **2 workflow runs**                                           |**Branch**|
|---------------------------------------------------------------|----------|
| `Initialize prod` - CD (Deploy to VPS) - *failed*             |   prod   |
| `Initial commit` - CI (Build & push) - *running then success* |   main   |

> Don’t worry about the failed CD workflow, It fails because your repository isn’t yet connected to your VPS through GitHub Secrets.

### Step 2 - Connect Your VPS via Secrets

To allow [GitHub Actions](https://github.com/features/actions) to deploy your app on your server,
you’ll need to add a few secrets to your repository.

Go to 
`Settings → Developpers settings → Personal access token → New token (classic)`,
name it and toggle only the scope `read:packages`.

> Only needed for private repositories.
> If the image belongs to an organization, make sure to enable SSO (Single Sign-On) for the token.

Go to
`Settings → Secrets and variables → Actions → New repository secret`,
and add the following:

| Secret | Description |
|--------|--------------|
| `VPS_HOST` | Your VPS IP address |
| `VPS_USER` | SSH user (`root`, `ubuntu`, or custom) |
| `VPS_SSH_KEY` | Your private SSH key (the public key must be in `~/.ssh/authorized_keys` on your VPS) |
| `GHCR_PAT`  | GitHub Personal Access Token if your repository and GHCR images are private |

> Once added, GitHub Actions will be able to:
> - Connect to your VPS via SSH  
> - Pull your Docker image from GHCR  
> - Restart the app automatically with Caddy handling HTTPS  

### Step 3 - Configure Your VPS Environment File

Your VPS needs an environment file that defines key variables used during deployment.
We’ll create it in `/opt/folio/.env.prod` (you can change the path if you prefer).

```bash
ssh <user>@<ip>
sudo mkdir -p /opt/folio
sudo chown $(whoami):$(whoami) /opt/folio
nano /opt/folio/.env.prod
```

Example content based on `.env.example`

```bash
# GHCR
OWNER=username
REPO=repository
GHCR_PAT=ghp_xxx

# CADDY
DOMAIN=your.dns.example
EMAIL=your@contact.mail
TZ=Europe/Paris
```

> This file will be automatically sourced by your CD (Continuous Deployment) workflow each time it runs.
> It provides the environment variables needed for Caddy and your GitHub image reference.

In your `.github/workflows/cd.yaml`, ensure the environment file path matches your setup:

```yaml
name: CD (Deploy to VPS)
on:
  push:
    branches: [ prod ]
  workflow_dispatch: {}

permissions:
  contents: read
  packages: read

env:
  ENV_FILE: /opt/folio/.env.prod  # Change this if your env file is elsewhere
```

Push your changes to the main branch

```bash
git add .github/workflows/cd.yaml
git commit -m ".env file location"
git push
```
> This will trigger the CI (Build & Push) workflow.
> Wait for it to complete successfully before moving on to the next step.

### Step 4 - Fix your branches histories

Since this is your **first deployment** after creating your repository from the template,
your main and prod branches have unrelated histories.
This cause the following error when merging:

```bash
fatal: refusing to merge unrelated histories
```

To fix this, run the following commands once:

```bash
git checkout prod
git reset --hard main
git push -u origin prod --force
```

This aligns both branches so future deployments with
`make prod` work normally.

> You only need to do this once per project clone. Future merges will work seamlessly.

### Step 5 - Trigger the Deployment

Now that your secrets and branches are configured, you can deploy to production:

```bash
make prod
```

This triggers the **CD (Deploy to VPS)** workflow, which will:
1. Connect to your VPS  
2. Pull your latest image from GHCR (pushed by the CI Workflow on the main branch)
3. Launch your app with Caddy and HTTPS automatically  

### Step 6 - Verify Your Deployment

Once the workflow finishes successfully, your app should be running on your VPS.

You can check it by running:

```bash
ssh <user>@<ip>
docker ps
```

You should see a container named after your repository — for example:

```
CONTAINER ID   IMAGE                                 COMMAND                  STATUS         PORTS
abc1234        ghcr.io/username/repository:main     "/usr/bin/caddy run…"    Up 2 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

#### Access Your Site

Now, simply open your browser and go to:
```
https://yourdomain.example
```
If you haven’t set up a domain yet, you can still access it via:

```
https://<your-vps-ip>
```
> Note: HTTPS may show a warning the first time if you’re using a self-signed or internal certificate.

### Step 7 - Just develop your app

From now on, your loop is simple and fast:

1. **Develop locally**
   ```bash
   make dev
   ```
   - Runs SvelteKit with hot reload on `http://localhost:5173`
   - Your changes reload instantly as you edit files in `svelte/`

2. **Test a production build locally (no HTTPS)**
   ```bash
   make preview
   ```
   - Builds the app and serves static files via Caddy on `http://localhost`
   - Useful for testing your optimized build locally before deploying.

3. **Push to `main` as often as you like**
   ```bash
   git add .
   git commit -m "feat: update section"
   git push
   ```
   - Each push to `main` triggers the **CI (Build & Push)** workflow
   - **Wait for CI to finish successfully** (image published to GHCR)

4. **Promote to production**

   - When `main` is ready for production, go back to [**Step 5**](#step-5---trigger-the-deployment).
   - This triggers the **CD (Deploy to VPS)** workflow and updates your live site.

> **Info:**
> The CI workflow automatically triggers only when files inside `svelte/` or your workflow files change.  
> So if you update documentation (like this README), it won’t rebuild or push a new image unnecessarily.