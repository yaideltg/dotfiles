# Hugo Pipes: data, CSS, JS, images

Sources: `resources.Get "path"` (from `assets/`), page resources (`.Resources.Get`), `resources.GetRemote`. Files in `static/` cannot be processed. A resource is published only when you call `.RelPermalink`/`.Permalink`/`.Publish`.

## Remote data (the only correct pattern)
```go-html-template
{{ $data := dict }}
{{ $url := "https://api.example.org/items.json" }}
{{ $opts := dict "headers" (dict "Authorization" (printf "Bearer %s" (getenv "HUGO_API_TOKEN"))) }}
{{ with try (resources.GetRemote $url $opts) }}
  {{ with .Err }}{{ errorf "%s" . }}
  {{ else with .Value }}{{ $data = .Content | transform.Unmarshal }}
  {{ else }}{{ errorf "Unable to get remote resource %q" $url }}
  {{ end }}
{{ end }}
```
- A 404 yields nil `.Value` (handled by the last `else`). Cache control: `[caches.getresource] maxAge = '1h'`. Allowed hosts: `security.http.urls`.
- Local: `{{ with resources.Get "data/items.json" }}{{ $data = . | transform.Unmarshal }}{{ end }}`.
- Remote images work the same and can then be `.Process`ed.

## CSS partial (`_partials/css.html`) — Dart Sass
```go-html-template
{{ with resources.Get "scss/main.scss" }}
  {{ $opts := dict
      "transpiler" "dartsass"
      "targetPath" "css/main.css"
      "outputStyle" (cond hugo.IsDevelopment "expanded" "compressed")
      "enableSourceMap" hugo.IsDevelopment
      "includePaths" (slice "node_modules") }}
  {{ with . | css.Sass $opts }}
    {{ if hugo.IsDevelopment }}
      <link rel="stylesheet" href="{{ .RelPermalink }}">
    {{ else }}
      {{ with . | fingerprint }}
        <link rel="stylesheet" href="{{ .RelPermalink }}" integrity="{{ .Data.Integrity }}" crossorigin="anonymous">
      {{ end }}
    {{ end }}
  {{ end }}
{{ end }}
```
Needs the `sass` (Dart Sass) binary on PATH (`brew install sass/sass/sass`, `npm i -g sass-embedded` alternatives, snap/choco/scoop) and allowed in `security.exec.allow`. Check with `hugo env`. Pass Hugo values into Sass: `"vars" (dict "primary" site.Params.color)` → `@use "hugo:vars" as v;`. Silence noisy dependency warnings: `"silenceDeprecations" (slice "import")`.

## Tailwind CSS v4
```bash
npm i -D tailwindcss @tailwindcss/cli   # Node ≥ 22
```
`assets/css/main.css`:
```css
@import "tailwindcss";
@source "hugo_stats.json";
```
hugo.toml:
```toml
[build.buildStats]
  enable = true
[[build.cachebusters]]
  source = 'assets/notwatching/hugo_stats\.json'
  target = 'css'
[[build.cachebusters]]
  source = '(postcss|tailwind)\.config\.js'
  target = 'css'
[module]
  [[module.mounts]]
    source = 'assets'
    target = 'assets'
  [[module.mounts]]
    disableWatch = true
    source = 'hugo_stats.json'
    target = 'assets/notwatching/hugo_stats.json'
```
`_partials/css.html`:
```go-html-template
{{ with (templates.Defer (dict "key" "global")) }}
  {{ with resources.Get "css/main.css" }}
    {{ $opts := dict "minify" (not hugo.IsDevelopment) }}
    {{ with . | css.TailwindCSS $opts }}
      {{ if hugo.IsDevelopment }}
        <link rel="stylesheet" href="{{ .RelPermalink }}">
      {{ else }}
        {{ with . | fingerprint }}<link rel="stylesheet" href="{{ .RelPermalink }}" integrity="{{ .Data.Integrity }}" crossorigin="anonymous">{{ end }}
      {{ end }}
    {{ end }}
  {{ end }}
{{ end }}
```
Note: once you declare any `[[module.mounts]]` for a component, the default mount for that component is replaced — hence re-adding `assets`.

## PostCSS (autoprefixer etc.)
`npm i -D postcss postcss-cli autoprefixer`, `postcss.config.js`, then `{{ $css := $css | css.PostCSS }}` (usually `if hugo.IsProduction`).

## Bundling / minifying plain CSS
`{{ $css := slice (resources.Get "css/a.css") (resources.Get "css/b.css") | resources.Concat "css/bundle.css" | minify | fingerprint }}`

## JavaScript (esbuild)
```go-html-template
{{ with resources.Get "js/main.js" }}
  {{ $opts := dict
      "targetPath" "js/main.js"
      "minify" (not hugo.IsDevelopment)
      "sourceMap" (cond hugo.IsDevelopment "linked" "none")
      "target" "es2020"
      "params" (dict "apiURL" site.Params.apiURL) }}
  {{ with . | js.Build $opts }}
    {{ if hugo.IsDevelopment }}<script src="{{ .RelPermalink }}" defer></script>
    {{ else }}{{ with . | fingerprint }}<script src="{{ .RelPermalink }}" integrity="{{ .Data.Integrity }}" crossorigin="anonymous" defer></script>{{ end }}{{ end }}
  {{ end }}
{{ end }}
```
- In JS: `import * as params from '@params';`. npm packages resolve from `node_modules`; TS/JSX supported natively (`.ts`, `.tsx`; set `"JSX" "automatic"` for React).
- `"format" "esm"` + `<script type="module">` for modules. `js.Batch` for multiple entry points with shared chunks (islands/components).
- `"externals" (slice "…")`, `"defines" (dict "process.env.NODE_ENV" "\"production\"")`.

## Images
Only from page bundles, `assets/`, or remote — not `static/`.
```go-html-template
{{ with .Resources.GetMatch (.Params.image | default "cover.*") }}
  {{ $small := .Process "resize 600x webp q80" }}
  {{ $large := .Process "resize 1200x webp q80" }}
  {{ $fallback := .Resize "1200x" }}
  <picture>
    <source type="image/webp" srcset="{{ $small.RelPermalink }} 600w, {{ $large.RelPermalink }} 1200w" sizes="(max-width: 700px) 100vw, 1200px">
    <img src="{{ $fallback.RelPermalink }}" width="{{ $fallback.Width }}" height="{{ $fallback.Height }}" alt="{{ $.Title }}" loading="lazy" decoding="async">
  </picture>
{{ end }}
```
- Methods: `.Resize "600x"` (keep ratio) · `.Fit "600x400"` (within box) · `.Fill "600x400 Smart"` (crop to exact) · `.Crop "600x400 TopLeft"` · `.Process "<action> <spec> <format> qNN rNN <filter> <anchor>"` · `.Filter (images.GaussianBlur 6) (images.Grayscale)` · `.Colors` (dominant colours) · `.Exif` (Date, Lat, Long, Tags).
- Formats: `jpg png gif webp avif (v0.162+) tiff bmp`. Quality `q1–100`, rotation `r90`, `bgColor`, `lossless` hint, anchors `Smart Center TopLeft …`, filters `Lanczos CatmullRom Box …`.
- SVG is a resource but not processable — output as is.
- Global defaults in `[imaging]`; processed results cached under `resources/_gen/images` (keep in CI cache to speed builds).
- Skip processing for GIF animations unless needed; always emit width/height (CLS).
