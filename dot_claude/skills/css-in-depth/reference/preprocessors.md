# Preprocessors (Sass/Less) & PostCSS — When and How

Condensed from *CSS in Depth*, Appendix B. Load this only when the project already uses (or is deciding whether to adopt) Sass/Less/PostCSS. Modern native CSS (custom properties, nesting, `calc()`) has closed much of the historical gap — check whether native CSS already covers the need before reaching for tooling.

## What a preprocessor actually does
Compiles a superset source file (`.scss`, `.less`) into plain CSS. It adds zero runtime features to the browser — everything happens at build time. Its value is entirely in author-time convenience.

## Sass features worth knowing
- **Variables** (`$brand-blue: #0086b3;`) — like custom properties but compile-time only (no runtime cascade/inheritance, no JS access). Prefer native CSS custom properties unless you specifically need compile-time-only behavior or must support very old browsers.
- **Inline arithmetic**: `$padding * 2` — good for deriving related values from one source number.
- **Nesting**: mirrors HTML structure in the stylesheet; `&` refers to the outer selector (e.g. `&.is-active`). WARNING: nesting increases the compiled selector's specificity and depth — don't nest more than 2-3 levels, and don't let it become a substitute for proper class-based scoping (see architecture.md / BEM).
- **Nesting media queries** inside a rule's own declaration block keeps a selector's responsive variants next to its base styles instead of duplicating the selector far away in the file.
- **Partials + `@import`**: split a stylesheet into many small files (e.g. one per module — mirrors the modular-CSS file-per-component pattern in architecture.md) compiled into a single output file — organization benefit with no extra network requests.
- **Mixins** (`@mixin`/`@include`): reusable declaration blocks, optionally parameterized like a function (`@mixin alert-variant($color, $bg-color)`). Output duplicates the mixin's CSS at every `@include` site — verbose but simple and predictable. Do NOT use mixins to hand-roll vendor prefixes — use Autoprefixer (a PostCSS plugin) instead.
- **`@extend`**: groups selectors that share a base together into one combined ruleset (shorter compiled output than a mixin) instead of duplicating declarations, letting HTML use only one class instead of two. Tradeoff: `@extend` moves the extending selector to the location of the EXTENDED rule in the output, which can quietly change your intended source-order/cascade behavior — prefer mixins unless you specifically want the class-count reduction `@extend` gives you.
- **Color functions**: `darken()`, `lighten()`, `saturate()`, `desaturate()`, `adjust-hue()`, `rgba($color, 0.5)` — derive related shades from one source variable so they all update together.
- **Loops** (`@for $i from 2 to 5 { ... }`): generate repetitive rulesets (e.g. staggered `:nth-child` transition-delays) parametrically instead of hand-writing each one — trivial to change the count or increment later.

## PostCSS ecosystem
- PostCSS itself is just a plugin-driven transform pipeline — no built-in features until you add plugins.
- **Autoprefixer** — the single most valuable plugin: automatically adds/removes vendor prefixes based on a configured browser support list and live caniuse.com data. Use this instead of ever hand-writing vendor prefixes or mixin-based prefixing.
- **cssnano** — minifier; use alongside (not instead of) server-side gzip/brotli compression.
- **cssnext / PreCSS** — polyfill-style plugins emulating upcoming/Sass-like syntax; treat as experimental, keep such rules separable from stable code since the underlying spec may still change before native browser support lands.

## Practical guidance
- The most valuable Sass feature for a growing project is partials (file-per-module organization) — pairs naturally with the modular-CSS approach in `architecture.md`.
- Always run production CSS through Autoprefixer rather than hand-authoring or mixin-authoring vendor prefixes.
- Everything a preprocessor outputs is still ordinary CSS — cascade, specificity, and box-model rules from `fundamentals.md` apply unchanged to the compiled result.
