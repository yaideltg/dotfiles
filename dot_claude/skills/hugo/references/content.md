# Content organization

## Bundles
```
content/
├── _index.md                 home (branch bundle)
├── posts/
│   ├── _index.md             section page (branch bundle, has children)
│   ├── my-first-post/        leaf bundle: page + its resources
│   │   ├── index.md
│   │   ├── cover.jpg
│   │   └── data.csv
│   └── quick-note.md         single-file page (no resources)
└── about.md
```
- `index.md` = leaf (no child pages; everything beside it is a page resource). `_index.md` = branch (home, section, taxonomy, term; resources beside it are only non-page files).
- Each top-level dir is a section; nested dirs are sections only if they contain `_index.md`.
- Prefer leaf bundles for anything with images — enables image processing and keeps content portable.
- Resource access: `.Resources.Get "cover.jpg"`, `.Resources.GetMatch "cover.*"`, `.Resources.Match "gallery/*"`, `.Resources.ByType "image"`. Resource metadata via front matter `resources: [{src: 'gallery/*', title: 'Gallery :counter'}]`.

## Front matter (YAML shown; TOML `+++` equally fine — stay consistent)
```yaml
---
title: 'My First Post'
date: 2026-09-01T10:00:00+02:00
lastmod: 2026-09-10          # or from git with enableGitInfo
publishDate: 2026-09-01       # future → hidden unless -F
expiryDate: 2027-09-01
draft: false                  # drafts only with -D
description: 'Used for meta description / OG'
summary: 'Optional manual summary'   # else <!--more--> or auto summary
slug: 'first-post'
url: '/custom/path/'          # overrides everything; avoid unless needed
aliases: ['/old/url/']        # generates redirects
weight: 10                    # ordering
tags: ['hugo', 'go']
categories: ['web']
type: 'docs'                  # layout type override
layout: 'wide'                # picks page layout named wide
keywords: ['…']
menus:
  main:
    weight: 20
outputs: ['html', 'json']
params:                       # custom fields go HERE → .Params.image
  image: 'cover.jpg'
  toc: true
build:
  render: always              # always | link | never
  list: always                # always | local | never
  publishResources: true
---
```
Put custom keys under `params:` (clean, future-proof); `.Params.x` works for both.
Date sources are configurable via `[frontmatter] date = [':filename', ':default']` (`:git`, `:fileModTime`).

## Cascade (branch bundles & config)
```yaml
# content/docs/_index.md
cascade:
  - params:
      showSidebar: true
    target:
      kind: page
      path: '{/docs/**}'
      environment: production
  - build: {list: local, render: never}   # e.g. private area
    target: {path: '/docs/internal/**'}
```

## Headless bundle (content used elsewhere, not published)
```yaml
# content/snippets/index.md
build: {render: never, list: never, publishResources: false}
```
Fetch with `site.GetPage "/snippets"` then `.Resources.Match "*.md"` and `.Content`.

## Taxonomies & terms
- Config `[taxonomies]` (singular = plural). Kinds: `taxonomy` (/tags/) and `term` (/tags/hugo/). Term pages can have content: `content/tags/hugo/_index.md`.
- Templates: `.Site.Taxonomies.tags`, `.GetTerms "tags"`, on term pages `.Pages`.
- Disable: `disableKinds = ['taxonomy', 'term']`.

## Menus
Define in config (`[[menus.main]]` with `pageRef`) or front matter `menus`. Render: `range .Site.Menus.main` with `.Name`, `.URL`, `.HasChildren`, `.Children`, `$.IsMenuCurrent "main" .`, `$.HasMenuCurrent "main" .`.

## URLs
- Permalinks per kind (`[permalinks.page]`, `[permalinks.section]`, `[permalinks.term]`) with tokens `:year :month :day :slug :slugorfilename :title :section :sections[1:] :contentbasename`.
- `uglyURLs = true` → `/post.html`. Keep `baseURL` with trailing slash.
- Link internally with `ref`/`relref` shortcodes, `.GetPage` + `.RelPermalink`, or a link render hook resolving `.Destination` via `.Page.GetPage`.

## Summaries
Manual `<!--more-->` divider > front-matter `summary` > automatic (`summaryLength`). Use `.Summary` (HTML) and `.Truncated`.

## Archetypes
`archetypes/default.md` and per-section `archetypes/posts.md` or bundle dirs `archetypes/posts/index.md` (+ files). Templates have `.Date`, `.File.ContentBaseName`:
```
---
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
date: {{ .Date }}
draft: true
---
```
`hugo new content posts/my-post/index.md` (bundle) or `posts/my-post.md`.

## Content adapters (v0.126+) — pages from data
`content/books/_content.gotmpl` (one per dir per language):
```go-html-template
{{ $url := "https://example.org/books.json" }}
{{ with try (resources.GetRemote $url) }}
  {{ with .Err }}{{ errorf "%s" . }}
  {{ else with .Value }}
    {{ range .Content | transform.Unmarshal }}
      {{ $.AddPage (dict
          "kind" "page" "path" .slug "title" .title
          "dates" (dict "date" (time.AsTime .date))
          "content" (dict "mediaType" "text/markdown" "value" .summary)
          "params" (dict "author" .author)) }}
    {{ end }}
  {{ else }}{{ errorf "Unable to get %q" $url }}
  {{ end }}
{{ end }}
```
Also `$.AddResource`, `$.Store`, `$.EnableAllLanguages`. Local data: `resources.Get "books.json"` (assets/) or `hugo.Data.books`.

## Multilingual
```toml
defaultContentLanguage = 'en'
defaultContentLanguageInSubdir = false
[languages.en]
  weight = 1
  label = 'English'
  title = 'My Site'
[languages.fr]
  weight = 2
  label = 'Français'
  [languages.fr.params]
    subtitle = '…'
```
- `languageName` was deprecated in v0.158.0 (removed in a future release) — use `label` instead. `.Language.Label` reads it in templates (`.Language.LanguageName` still works but warns and will break). Since `label` is a single field, if other templates key off it for a short code (e.g. `"FR"`/`"EN"`) don't overload it with a display name too — compare on `.Language.Lang` instead, or keep language-name strings in a template-local `dict` / i18n keyed by `.Lang`.
- By filename: `about.en.md` / `about.fr.md`; by directory: `[languages.fr] contentDir = 'content/fr'` (or module mounts with `lang`). Translations link by same path or `translationKey`.
- Templates: `.Translations`, `.AllTranslations`, `.Language.Lang`, `.Language.Label`, `T "readMore"` with `i18n/fr.toml`: `readMore = 'Lire la suite'`, `relLangURL`.
- v0.153+ also supports `version` and `role` dimensions (sites matrix) — advanced; only use when asked.

## Related content
`[related]` config with indices (`keywords`, `tags`, `date`) → `{{ range site.RegularPages.Related . | first 5 }}`.

## Data files
`data/team.yaml` → `hugo.Data.team`. Prefer `assets/` + `resources.Get … | transform.Unmarshal` when you also want caching/fingerprinting.
