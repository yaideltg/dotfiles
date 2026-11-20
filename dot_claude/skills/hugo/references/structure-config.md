# Project structure & configuration

## Skeleton (`hugo new project mysite` / `hugo new site mysite`; `--format yaml` optional)
```
archetypes/   front-matter templates for `hugo new content`
assets/       processed by Hugo Pipes (scss, js, images) — only published if used
config/       optional config directory (alternative to hugo.toml)
content/      Markdown content (sections = dirs)
data/         YAML/JSON/TOML/CSV → hugo.Data
i18n/         translation tables (en.toml …) → T / i18n
layouts/      templates (see templates.md)
static/       copied verbatim to public/ (favicons, robots overrides, fonts you don't process)
themes/       only when not using modules
public/       output — git-ignore
resources/    _gen cache for processed assets
hugo.toml
```
Everything in these dirs is a **mount**; themes/modules merge on top (project wins).

## hugo.toml baseline
```toml
baseURL = 'https://example.org/'
locale = 'en-US'          # languageCode also accepted
title = 'My Site'
enableRobotsTXT = true
enableGitInfo = true      # gives .GitInfo and lastmod from git
timeZone = 'Europe/Paris'

[pagination]
  pagerSize = 10
  path = 'page'

[taxonomies]
  tag = 'tags'
  category = 'categories'

[permalinks.page]
  posts = '/:year/:month/:slug/'
[permalinks.section]
  posts = '/posts/'

[menus]
  [[menus.main]]
    name = 'Blog'
    pageRef = '/posts'
    weight = 10

[markup.goldmark.renderer]
  unsafe = false          # true only if Markdown must contain raw HTML
[markup.goldmark.parser.attribute]
  block = true            # {.class} after blocks
[markup.goldmark.extensions.passthrough]
  enable = true
  [markup.goldmark.extensions.passthrough.delimiters]
    block = [['\[', '\]'], ['$$', '$$']]
    inline = [['\(', '\)']]
[markup.highlight]
  noClasses = false       # use CSS classes; generate CSS with `hugo gen chromastyles` or css.ChromaStyles

[params]
  description = '…'
  [params.author]
    name = 'Jane Doe'
  [params.social]
    github = 'jane'

[outputs]
  home = ['html', 'rss']  # add 'json' for a search index
  section = ['html', 'rss']

[imaging]
  quality = 80
  resampleFilter = 'Lanczos'
  anchor = 'Smart'

[security.exec]
  allow = ['^(dart-)?sass(-embedded)?$', '^go$', '^git$', '^node$', '^npx$', '^postcss$', '^tailwindcss$']
```
Config keys are case-insensitive; params keys are lowercased — access as `.Site.Params.author.name`.

## Config directory & environments
```
config/_default/hugo.toml     # base
config/_default/params.toml   # file named after a root key → omit the [params] header
config/_default/menus.en.toml
config/_default/languages.toml
config/production/hugo.toml   # overrides for `hugo` (default env: production)
config/development/params.toml# overrides for `hugo server` (default env: development)
```
`--environment staging` / `HUGO_ENVIRONMENT`. Theme/module config is merged under the project's; control with `_merge = 'none'|'shallow'|'deep'` inside a key.

## Environment variables
`HUGO_BASEURL`, `HUGO_ENVIRONMENT`, `HUGO_ENABLEGITINFO`, `HUGO_PARAMS_API_KEY`… Nested keys with `_`; if the key itself contains `_`, use a custom delimiter: `HUGOxPARAMSxAPI_KEY`. In templates read with `getenv` only if allowed in `security.funcs.getenv` (default `^HUGO_`, `^CI$`).

## Security
- `security.exec.allow` — binaries Hugo may run (Sass, Node, PostCSS, Tailwind, git, go).
- `security.http.urls` / `mediaTypes` — what `resources.GetRemote` may fetch.
- `security.allowContent` (v0.162) — raw `.html` content files denied by default; `allowContent = ['.*']` to re-enable.
- `markup.goldmark.renderer.unsafe` — raw HTML inside Markdown.

## Useful config for build output
```toml
[build.buildStats]
  enable = true            # writes hugo_stats.json (needed for Tailwind / PurgeCSS)
[minify]
  minifyOutput = true      # or pass --minify
[sitemap]
  changeFreq = 'weekly'
  priority = 0.5
```
