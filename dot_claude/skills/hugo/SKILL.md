---
name: hugo
description: Current (v0.146+ through v0.166, 2026) best practices for Hugo static sites — project structure, the NEW layouts/ template system (_partials, _shortcodes, _markup, home.html, no _default), content organization (page bundles, front matter, cascade, taxonomies, content adapters, multilingual), hugo.toml config, Hugo Pipes (Dart Sass, Tailwind v4, js.Build, image processing, resources.GetRemote+try), modules/themes, and deployment. Use this skill whenever the user works on a Hugo website or theme — any hugo.toml/config.toml, layouts/, content/ with front matter, archetypes, shortcodes, render hooks, Go templates ({{ .Title }}, .Site, .Pages), `hugo server`, a Hugo build error or deprecation warning, or migrating/upgrading an old Hugo site — even if the user doesn't say "Hugo" explicitly.
---

# Hugo — current best practices (verified against v0.166.0, Sept 2026)

Your training data is full of **pre-2025 Hugo idioms that are now removed or deprecated**. Before writing any template, config or front matter, apply the rules below. When unsure about a function's current signature, check `https://gohugo.io/functions/<ns>/<name>/` rather than guessing.

## First step on any Hugo project
1. `hugo version` → note version and edition (need **extended** for Sass/WebP; ≥ v0.146.0 for the layout rules below). If < 0.146, say so and follow `references/deprecations.md` → "Migrating an old site".
2. Look at: config (`hugo.toml` or `config/_default/`), `layouts/`, `content/` tree, `go.mod` (modules) or `themes/`, `package.json` (Tailwind/PostCSS).
3. Match the existing project's conventions (TOML vs YAML front matter, theme vs module) unless they are deprecated.

## Non-negotiable rules (things models get wrong)
**Layouts (v0.146.0 template system):**
- No `layouts/_default/`. Templates live at `layouts/` root: `baseof.html`, `home.html` (not `index.html`), `page.html`, `section.html`, `taxonomy.html`, `term.html`, optional `all.html`; `single.html`/`list.html` still work as generic fallbacks.
- `layouts/_partials/` (not `partials/`), `layouts/_shortcodes/` (not `shortcodes/`), render hooks in `layouts/_markup/`. These `_` dirs may also appear inside a page-path dir.
- Any non-`_` dir in `layouts/` is a **page path** (e.g. `layouts/docs/page.html` applies to `/docs/**`). Beware a section dir colliding with a same-named root page.
- Base variants: `baseof.list.html`, not `list-baseof.html`.
- Embedded templates: `{{ partial "opengraph.html" . }}`, `{{ partial "twitter_cards.html" . }}`, `{{ partial "schema.html" . }}`, `{{ partial "pagination.html" . }}` — not `template "_internal/..."`.

**APIs:**
- Remote/data: `resources.GetRemote` wrapped in `try` + `transform.Unmarshal`. Never `getJSON`/`getCSV`, never `.Err` on the resource.
- `hugo.IsServer`, `hugo.IsProduction`, `hugo.IsDevelopment`, `hugo.IsMultilingual`, `hugo.Data`, `hugo.Sites` — not `.Site.IsServer`, `.Site.IsMultiLingual`, `site.Data`, `.Sites`.
- `.Site.Params.author` / `.Site.Params.social` — not `.Site.Author`, `.Site.Social`.
- `.Next`/`.Prev`, `.Site.Lastmod`, `.Sites.Default`, `.Paginator.PagerSize`.
- `css.Sass` (with `"transpiler" "dartsass"`), `css.PostCSS`, `js.Babel`, `hash.FNV32a` — not `resources.ToCSS`/`resources.PostCSS`/`resources.Babel`/`crypto.FNV32a`.
- Tailwind v4: `css.TailwindCSS` inside `templates.Defer`, npm CLI (`@tailwindcss/cli`, Node ≥ 22); standalone binary unsupported since v0.161.0.

**Config:** `hugo.toml` (not `config.toml`); `[pagination] pagerSize` / `path` (not `paginate`, `paginatePath`); per-language custom params under `[languages.xx.params]`; external binaries must be listed in `security.exec.allow`.

Full old→new table: `references/deprecations.md`.

## Decision guide
| Task | Do this | Details |
|---|---|---|
| New page with images/files | Leaf bundle `post-slug/index.md` + resources beside it | content.md |
| Section/list page | `_index.md` (branch bundle) | content.md |
| Shared front matter for a subtree | `cascade` in the section's `_index.md` | content.md |
| Pages from JSON/API/CSV | Content adapter `content/<sec>/_content.gotmpl` | content.md |
| Content-only snippet used elsewhere | Headless bundle (`build.render = 'never'`) | content.md |
| Customize Markdown links/images/headings/code/tables | Render hook in `layouts/_markup/` | templates.md |
| Reusable markup inside content | Shortcode in `layouts/_shortcodes/` (prefer render hooks when plain Markdown suffices) | templates.md |
| Styles | Dart Sass `css.Sass` or Tailwind v4 `css.TailwindCSS` + `templates.Defer`; fingerprint in production | pipes.md |
| JS | `js.Build` (esbuild); `js.Batch` for split bundles | pipes.md |
| Images | Put in `assets/` or page bundle (NOT `static/`), `.Process "resize 800x webp q80"`, emit width/height | pipes.md |
| Theme | Hugo Module (`hugo mod init`, `[[module.imports]]`) over git submodule | deploy.md |
| Per-environment settings | `config/_default/` + `config/production/` | structure-config.md |
| Internal links | `ref`/`relref` or a link render hook; never hardcoded hosts | templates.md |
| Deploy | GitHub Actions → Pages artifact; pin `HUGO_VERSION`; `hugo --gc --minify` | deploy.md |

## Reference files (read only what the task needs)
- `references/deprecations.md` — removed/deprecated APIs with replacements, version timeline, migration checklist for old sites.
- `references/structure-config.md` — directory layout, config files & directory, merging, env vars, security, key config snippets.
- `references/content.md` — bundles, front matter fields, build options, cascade, taxonomies, menus, URLs, multilingual, content adapters.
- `references/templates.md` — lookup order, baseof/blocks, context rules, common functions/idioms, render hooks, shortcodes, pagination, SEO partials, performance.
- `references/pipes.md` — GetRemote+try, Sass, Tailwind v4, PostCSS, js.Build/Batch, fingerprint/SRI, image processing.
- `references/deploy.md` — CLI flags, modules, GitHub Pages workflow, Netlify/Cloudflare, `hugo deploy`, debugging.

## Working habits
- After changing templates/config, run `hugo --gc --printPathWarnings --printUnusedTemplates` (or `hugo server -D` while iterating) and fix every WARN/ERROR — deprecation warnings are future build failures.
- Debug values with `{{ debug.Dump . }}` / `{{ warnf "%v" $x }}`; inspect merged config with `hugo config`.
- Keep `.` vs `$` straight inside `range`/`with`; pass context explicitly to partials (`{{ partial "card.html" (dict "page" . "size" "sm") }}`).
- Git-ignore `public/` and `.hugo_build.lock`; commit `resources/_gen/` only if you want faster CI image builds.
- Hugo ships every few weeks: if a feature looks missing, check the release notes before inventing a workaround.
