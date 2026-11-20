# CLI, modules, deployment, debugging

## Install
Use the **extended** edition (extended/deploy if you need `hugo deploy`). Prebuilt binaries from GitHub releases, `brew install hugo`, `snap install hugo` (bundles Dart Sass), `winget install Hugo.Hugo.Extended`, or `CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest`. Distro packages are often outdated. Modules need Go; Tailwind/PostCSS need Node (≥ 22 for Tailwind v4).

## Commands
| Command | Use |
|---|---|
| `hugo new project|site <dir>` | scaffold (`--format yaml`) |
| `hugo new theme <name>` | theme skeleton |
| `hugo new content posts/x/index.md` | from archetype |
| `hugo server -D` | dev server, drafts; `-F` future, `-E` expired, `--disableFastRender`, `--navigateToChanged`, `--bind 0.0.0.0 --baseURL http://<ip>:1313`, `-p`, `--renderToMemory`/`-M`, `--poll 700ms`, `-O` open browser, `--tlsAuto` |
| `hugo` / `hugo build` | production build: `--gc --minify`, `-e staging`, `-b <url>`, `-d <dest>`, `--cleanDestinationDir` |
| diagnostics | `--printPathWarnings`, `--printUnusedTemplates`, `--printI18nWarnings`, `--templateMetrics --templateMetricsHints`, `--logLevel debug`, `--panicOnWarning` |
| `hugo config` | print merged config (`--format json`); `hugo config mounts` |
| `hugo env` | versions, Go, Sass/PostCSS availability |
| `hugo list drafts|future|expired|all` | content audit (CSV) |
| `hugo gen chromastyles --style=monokai > assets/css/syntax.css` | highlight CSS |
| `hugo convert toYAML|toTOML -o <dir>` | convert front matter |
| `hugo mod …` | modules (below) |
| `hugo deploy` | S3/GCS/Azure per `[deployment]` (extended/deploy edition) |

## Hugo Modules (preferred over git submodules)
```bash
hugo mod init github.com/me/mysite          # creates go.mod
```
```toml
[module]
  [module.hugoVersion]
    extended = true
    min = '0.146.0'
  [[module.imports]]
    path = 'github.com/owner/hugo-theme'     # no https://, no .git
  [[module.imports]]
    path = 'github.com/owner/shortcodes'
    [[module.imports.mounts]]
      source = 'layouts'
      target = 'layouts'
```
- `hugo mod get -u` (update all; `-u ./...` recursive; `hugo mod get github.com/x/y@v1.2.0`), `hugo mod tidy`, `hugo mod graph`, `hugo mod verify`, `hugo mod clean`, `hugo mod vendor` (→ `_vendor/`, used automatically; good for reproducible offline builds), `hugo mod npm pack` (merge JS deps into package.json).
- Local development of a theme: in `go.mod` add `replace github.com/owner/hugo-theme => ../hugo-theme`, or `HUGO_MODULE_REPLACEMENTS`.
- Private repos: `GOPRIVATE=github.com/org/*` + git credentials.
- Mounts remap any dir (`source`/`target`, `lang`, `includeFiles`, `excludeFiles`, `disableWatch`) — replaces old `contentDir`/`staticDir` tricks; e.g. mount `node_modules/bootstrap/scss` → `assets/scss/bootstrap`.
- Override theme files by placing the same path in the project (e.g. `layouts/_partials/header.html`).
- Git submodule alternative: `git submodule add https://github.com/owner/theme themes/theme` + `theme = 'theme'`; CI must checkout with `submodules: recursive`.

## GitHub Pages (Settings → Pages → Source: GitHub Actions)
`.github/workflows/hugo.yml`:
```yaml
name: Deploy Hugo site to Pages
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: false
defaults:
  run:
    shell: bash
jobs:
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.166.0
      HUGO_ENVIRONMENT: production
      TZ: Europe/Paris
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb
          sudo dpkg -i ${{ runner.temp }}/hugo.deb
      - name: Install Dart Sass
        run: sudo snap install dart-sass
      - uses: actions/checkout@v4
        with:
          submodules: recursive
          fetch-depth: 0            # for enableGitInfo / lastmod
      - uses: actions/setup-go@v5   # only if using modules
        with: { go-version: stable }
      - uses: actions/setup-node@v4 # only if package.json
        with: { node-version: 22 }
      - run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
      - id: pages
        uses: actions/configure-pages@v5
      - uses: actions/cache@v4
        with:
          path: ${{ runner.temp }}/hugo_cache
          key: hugo-${{ github.run_id }}
          restore-keys: hugo-
      - name: Build
        run: |
          hugo --gc --minify \
            --baseURL "${{ steps.pages.outputs.base_url }}/" \
            --cacheDir "${{ runner.temp }}/hugo_cache"
      - uses: actions/upload-pages-artifact@v3
        with: { path: ./public }
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```
Bump action major versions if GitHub has newer ones; always pin `HUGO_VERSION` to the version you test locally.

## Other hosts
- **Netlify** `netlify.toml`: `[build] command = "hugo --gc --minify"`, `publish = "public"`, `[build.environment] HUGO_VERSION = "0.166.0"`, `NODE_VERSION = "22"`, `GO_VERSION`; deploy previews: `command = "hugo -b $DEPLOY_PRIME_URL --buildDrafts --buildFuture"`.
- **Cloudflare Pages / Workers static assets**: build `hugo --gc --minify`, output `public`, env `HUGO_VERSION`.
- **GitLab Pages**: image `hugomods/hugo:exts-<version>` or `registry.gitlab.com/pages/hugo/hugo_extended:<version>`, job `pages` publishing `public`.
- **Self-hosted (VPS/nginx/Caddy)**: `hugo --gc --minify` then `rsync -avz --delete public/ user@host:/var/www/site/`; serve with long cache on fingerprinted assets.
- **hugo deploy**: `[[deployment.targets]] name = 'prod' url = 's3://bucket?region=eu-west-3'` + `[[deployment.matchers]]` for cache headers/gzip; `hugo deploy --target prod --invalidateCDN`.

## Debugging checklist
1. `hugo env` / `hugo version` — right edition & version? Sass found?
2. `hugo config | grep -i <key>` — did the setting actually merge?
3. Wrong template used → check lookup identifiers (kind, layout, type, page path); temporarily add `{{ warnf "using %s for %s" templates.Current.Name .Path }}` (v0.146+) or `{{ .Kind }}/{{ .Type }}` output.
4. Page missing → draft/future/expired? `build.list`/`render`? section lacks `_index.md`? `hugo list all`.
5. Asset missing → never referenced `.RelPermalink`? in `static/` instead of `assets/`? `security.exec` blocking the binary?
6. Stale output → `hugo --gc --cleanDestinationDir`, delete `resources/_gen`, restart server with `--disableFastRender`.
7. `debug.Dump` any value; `--printPathWarnings` for duplicate output paths.
