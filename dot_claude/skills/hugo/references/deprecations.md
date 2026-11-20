# Deprecations, removals & version timeline

Most items below were **removed in v0.156.0** (Feb 2026, "spring cleaning") after logging errors since ≤ v0.136.0. Treat every entry in the left column as a bug.

## Old → current
| Old | Current |
|---|---|
| `getJSON`, `data.GetJSON`, `getCSV`, `data.GetCSV` | `resources.GetRemote` (or `resources.Get`) + `try` + `transform.Unmarshal` |
| `(resources.GetRemote $u).Err` | `with try (resources.GetRemote $u)` → `.Err` / `.Value` (removed v0.141.0) |
| `.Site.Author`, `.Site.Authors`, `.Site.Social` | `.Site.Params.author`, `.Site.Params.authors`, `.Site.Params.social` |
| `.Site.IsServer` | `hugo.IsServer` |
| `.Site.IsMultiLingual` | `hugo.IsMultilingual` |
| `.Site.LastChange` | `.Site.Lastmod` |
| `.Site.Data` / `site.Data` | `hugo.Data` (v0.156.0) |
| `.Sites`, `.Page.Sites`, `.Site.Sites` | `hugo.Sites` (v0.156.0) |
| `.Sites.First` | `.Sites.Default` / `hugo.Sites.Default` |
| `.Site.AllPages`, `.Site.BuildDrafts`, `.Site.Languages` | deprecated v0.156.0 — iterate `hugo.Sites`, use `hugo.IsServer`/env |
| `.Page.NextPage` / `.PrevPage` | `.Next` / `.Prev` (or `.NextInSection` / `.PrevInSection`) |
| `.Paginator.PageSize` | `.Paginator.PagerSize` |
| config `paginate`, `paginatePath` | `[pagination] pagerSize`, `path` (v0.128.0) |
| config top-level `author` | `[params.author] name = '…'` |
| custom keys directly under `[languages.xx]` | `[languages.xx.params]` |
| config `languages.xx.languageName` | `languages.xx.label` (v0.158.0); read via `.Language.Label` |
| `resources.ToCSS` | `css.Sass` |
| `resources.PostCSS` / `resources.Babel` | `css.PostCSS` / `js.Babel` |
| `crypto.FNV32a` | `hash.FNV32a` |
| LibSass (`transpiler "libsass"`) | Dart Sass `"transpiler" "dartsass"` (LibSass deprecated v0.153.0) |
| Tailwind standalone binary / Tailwind v3 PostCSS flow | `css.TailwindCSS` + npm `@tailwindcss/cli` (v0.161.0) |
| `{{ template "_internal/opengraph.html" . }}` | `{{ partial "opengraph.html" . }}` |
| `layouts/_default/*` | `layouts/*` |
| `layouts/partials/`, `layouts/shortcodes/` | `layouts/_partials/`, `layouts/_shortcodes/` |
| `layouts/_default/_markup/` | `layouts/_markup/` |
| `layouts/index.html` | `layouts/home.html` |
| `list-baseof.html` | `baseof.list.html` |
| `taxonomy.html` serving term pages too | `taxonomy.html` + `term.html` (or `list.html`) |
| `config.toml` | `hugo.toml` (old name still read) |
| `_build` front matter key | `build` |

## Timeline of notable additions
- v0.120 `hugo.IsServer` etc. · v0.123 GetJSON deprecated · v0.126 content adapters (`_content.gotmpl`) · v0.128 `pagination` config · v0.134 `render-table` hook · v0.141 `try`, GetRemote `.Err` removed · v0.144-ish `templates.Defer`, `js.Batch`, `css.TailwindCSS` matured
- **v0.146.0 new template system** (layout dirs, lookup order, `all.html`)
- v0.153.0 LibSass deprecated; content dimensions `version` and `role` (sites matrix) beside `language`
- v0.154.0 partial decorators · v0.156.0 API removals, faster `where`/`sort`
- v0.161.0 Tailwind standalone binary dropped; version range queries
- v0.162.0 AVIF encode/decode; `security.allowContent` (raw `.html` content files denied by default)
- v0.165.0 `css.Sass` `importContext` · v0.166.0 Go 1.26.3 security fixes, `css.ChromaStyles`, KaTeX CSS ≥ 0.18.4 with `transform.ToMath`

## Migrating an old site (checklist)
1. Upgrade to latest extended; run `hugo` and collect every WARN/ERROR.
2. `git mv layouts/_default/* layouts/`; `git mv layouts/partials layouts/_partials`; `git mv layouts/shortcodes layouts/_shortcodes`; move `_markup`; rename `index.html`→`home.html`, `*-baseof.html`→`baseof.*.html`; add `term.html` if `taxonomy.html` was used for terms.
3. Same for the theme (or upgrade the theme/module).
4. Replace APIs per table (grep: `getJSON|getCSV|\.Site\.(Author|Social|IsServer|Data|LastChange)|paginate|ToCSS|_internal|NextPage|PrevPage`).
5. Rename `config.toml`→`hugo.toml`; move `paginate`; move language params.
6. Switch to Dart Sass / Tailwind v4 flow if applicable.
7. Rebuild with `--printPathWarnings --printUnusedTemplates`; diff `public/` against the old build.
