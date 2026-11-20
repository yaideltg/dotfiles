# Templates (v0.146+ system)

## Layout tree
```
layouts/
├── baseof.html          base skeleton with blocks
├── home.html            kind home
├── page.html            kind page (regular pages)
├── section.html         kind section
├── taxonomy.html        /tags/
├── term.html            /tags/hugo/
├── list.html single.html   generic fallbacks (optional)
├── all.html             catch-all for every kind (optional)
├── 404.html  robots.txt  sitemap.xml  rss.xml   (override embedded ones only if needed)
├── home.json            other output formats: <kind>.<format>.<ext>
├── _partials/  _shortcodes/  _markup/
└── docs/                page path → applies to content under /docs
    ├── page.html
    └── _partials/…      (scoped overrides)
```
**Lookup identifiers** (most → least important): front-matter `layout` → kind (`home|section|taxonomy|term|page`) → standard layout (`list|single`) → output format → `all` → language (`page.fr.html`) → media type → page path (nearest dir upward) → `type`. Partials are NOT context-aware: `partial "x.html"` resolves `_partials/x.html`.

## baseof + blocks
```go-html-template
{{/* layouts/baseof.html */}}
<!doctype html>
<html lang="{{ site.Language.LanguageCode }}" dir="{{ or site.Language.LanguageDirection `ltr` }}">
<head>{{ partial "head.html" . }}</head>
<body>
  {{ partial "header.html" . }}
  <main>{{ block "main" . }}{{ end }}</main>
  {{ partialCached "footer.html" . }}
</body>
</html>
```
```go-html-template
{{/* layouts/page.html */}}
{{ define "main" }}
  <article>
    <h1>{{ .Title }}</h1>
    {{ with .Date }}<time datetime="{{ .Format "2006-01-02" }}">{{ .Format "2 January 2006" }}</time>{{ end }}
    {{ .Content }}
  </article>
{{ end }}
```
```go-html-template
{{/* layouts/section.html */}}
{{ define "main" }}
  <h1>{{ .Title }}</h1>{{ .Content }}
  {{ $p := .Paginate (.Pages.ByDate.Reverse) }}
  {{ range $p.Pages }}<h2><a href="{{ .RelPermalink }}">{{ .LinkTitle }}</a></h2>{{ .Summary }}{{ end }}
  {{ partial "pagination.html" . }}
{{ end }}
```

## head partial (SEO)
```go-html-template
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} | {{ site.Title }}{{ end }}</title>
<meta name="description" content="{{ or .Description .Summary site.Params.description | plainify | truncate 160 }}">
<link rel="canonical" href="{{ .Permalink }}">
{{ range .AlternativeOutputFormats }}{{ printf `<link rel=%q type=%q href=%q title=%q>` .Rel .MediaType.Type .Permalink site.Title | safeHTML }}{{ end }}
{{ partial "opengraph.html" . }}
{{ partial "twitter_cards.html" . }}
{{ partial "css.html" . }}
```
`schema.html` emits microdata meta, not JSON-LD — write your own JSON-LD with `jsonify` if needed.

## Context rules
- `.` is the current context; inside `range`/`with` it changes. Use `$` for the template's top context, or bind: `{{ range $i, $p := .Pages }}`.
- `site` (global function) == `.Site` and works anywhere, including partials with custom dicts.
- Partials receive exactly one arg: pass `.` or `(dict "page" . "class" "x")`; return values via `{{ return $x }}` (partial used as function).
- `with … else with … else …` for nil checks; `or`/`default` for fallbacks; `cond` for ternary.

## Page collections — the idioms
```go-html-template
{{ range site.RegularPages }}                         all regular pages (current language)
{{ range where site.RegularPages "Section" "posts" }}
{{ range (where site.RegularPages "Type" "posts").ByDate.Reverse | first 5 }}
{{ range .Pages }}          children (pages + subsections) of a list page
{{ range .RegularPages }}   direct regular children;  .RegularPagesRecursive for all descendants
{{ range .Sections }}       child sections
{{ with site.GetPage "/about" }}<a href="{{ .RelPermalink }}">{{ .LinkTitle }}</a>{{ end }}
{{ range .Pages.GroupByDate "2006" }}<h2>{{ .Key }}</h2>{{ range .Pages }}…{{ end }}{{ end }}
{{ where .Pages "Params.featured" true }}   {{ where .Pages "Date" "ge" (now.AddDate -1 0 0) }}
{{ sort .Pages "Weight" "asc" }}  .ByWeight .ByTitle .ByLastmod  {{ .Pages | shuffle }}
```
Other staples: `.Permalink`/`.RelPermalink`, `.LinkTitle`, `.Kind`, `.Section`, `.Parent`, `.Ancestors`, `.IsHome`, `.IsSection`, `.IsPage`, `.InSection`, `.IsAncestor`, `.TableOfContents`, `.WordCount`, `.ReadingTime`, `.Lastmod`, `.GitInfo`, `.File.Dir`, `.Store`, `hugo.Version`, `hugo.Environment`, `absURL`, `relURL`, `urlize`, `markdownify`, `plainify`, `safeHTML`, `strings.*`, `collections.*`, `math.*`, `time.Format`, `lang.FormatNumber`, `transform.Unmarshal`, `jsonify`, `templates.Exists`, `debug.Dump`.

## Pagination
Config `[pagination] pagerSize`. Only ONE paginator per page: call `.Paginate` once (the first call wins). Use the embedded `{{ partial "pagination.html" . }}` (terse variant: `{{ partial "pagination.html" (dict "page" . "format" "terse") }}`) or loop `$p.Pagers` with `.PageNumber`, `.URL`, `$p.HasPrev`, `$p.Prev.URL`, `$p.HasNext`, `$p.Next.URL`.

## Render hooks (`layouts/_markup/`)
Files: `render-link.html`, `render-image.html`, `render-heading.html`, `render-codeblock.html`, `render-codeblock-<lang>.html` (e.g. `-mermaid`), `render-blockquote.html` (+ alerts `> [!NOTE]` via `.AlertType`), `render-table.html`, `render-passthrough.html` (math). Hugo has sensible embedded link/image hooks (`[markup.goldmark.renderHooks.link] enableDefault = true`, default for multilingual/multi-host).

Link hook resolving internal pages & marking externals:
```go-html-template
{{- $u := urls.Parse .Destination -}}
{{- $href := .Destination -}}
{{- if and (not $u.IsAbs) $u.Path -}}
  {{- with or (.PageInner.GetPage $u.Path) (.PageInner.Resources.Get $u.Path) -}}
    {{- $href = .RelPermalink -}}{{- with $u.Fragment }}{{ $href = printf "%s#%s" $href . }}{{ end -}}
  {{- else -}}{{- warnf "%s: link %q not found" $.PageInner.Path $.Destination -}}{{- end -}}
{{- end -}}
<a href="{{ $href }}"{{ with .Title }} title="{{ . }}"{{ end }}{{ if $u.IsAbs }} rel="external"{{ end }}>{{ .Text }}</a>
{{- /* chomp trailing newline */ -}}
```
Image hook: resolve `.Destination` from page resources, `.Process "resize 1200x webp"`, output `width`/`height`, `loading="lazy"`, `alt="{{ .PlainText }}"`.
Heading hook: `<h{{ .Level }} id="{{ .Anchor }}">{{ .Text }} <a href="#{{ .Anchor }}" class="anchor" aria-hidden="true">#</a></h{{ .Level }}>`.

## Shortcodes (`layouts/_shortcodes/`)
```go-html-template
{{/* _shortcodes/figure-note.html — use: {{< figure-note type="warn" >}}**md**{{< /figure-note >}} */}}
<aside class="note note-{{ .Get "type" | default "info" }}">{{ .Inner | .Page.RenderString }}</aside>
```
`{{< >}}` = inner not Markdown-processed (use `.Page.RenderString`); `{{% %}}` = inner rendered as Markdown. Access: `.Get 0`/`.Get "name"`, `.Inner`, `.Page`, `.Parent`, `.Params`, `.Position` (for errorf). Embedded: `figure`, `highlight`, `ref`, `relref`, `details`, `param`, `qr`, `youtube`, `vimeo`, `x`, `instagram`. Prefer Markdown + render hooks over shortcodes where possible (content stays portable).

## Performance
- `partialCached "footer.html" . ` (optionally with variant keys: `partialCached "nav.html" . .Section`) for context-independent output.
- Avoid ranging over `site.RegularPages` on every page; compute once in a cached partial or `hugo.Store`/`.Store`.
- Measure: `hugo --templateMetrics --templateMetricsHints`.
- `templates.Defer` delays a block until all pages are rendered (Tailwind, search index of used classes).
- `try` for recoverable errors; `errorf` fails the build, `warnf`/`warnidf` warn (silence ids with `ignoreLogs`).
