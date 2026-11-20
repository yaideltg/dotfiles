# CSS Fundamentals: Cascade, Units, Box Model

Deep-dive reference distilled from *CSS in Depth* (Keith J. Grant, Manning) chapters 1–3. Load this file when debugging specificity/cascade conflicts, choosing units, or fighting box-model/margin sizing issues.

## Contents
1. Cascade, specificity, inheritance
2. Relative units (em, rem, viewport units, custom properties)
3. Box model mastery

---

- Cascade resolves conflicts in 3 steps in order: (1) origin/importance, (2) specificity, (3) source order.
- Origins in priority order (low→high): user agent < author < author !important. (later: user styles sit between UA and author, rare)
- Specificity = (IDs, classes, tags) triplet, e.g. #id.class.class tag = 1,2,1. Compare left-to-right; higher category always wins regardless of count in lower categories (10 classes never beat 1 ID).
- Pseudo-classes (:hover) and attribute selectors ([type=]) = same specificity as a class. Universal selector (*) and combinators (>,+,~) add ZERO specificity.
- Inline style (style="") acts like specificity 1,0,0,0 — beats any selector; only !important or another inline can override.
- RULE OF THUMB: avoid ID selectors in stylesheets (hard to override later); avoid !important (escalates into "specificity arms race"). Prefer lowering the specificity of the thing you need to override rather than raising the specificity of the override.
- Three ways to fix a losing selector, in order of preference: (1) !important (last resort/naive), (2) raise specificity of the target selector, (3) BEST: lower the specificity of the original overly-specific selector (e.g. change #nav to .nav), (4) rely on source order when specificities are made equal — but this is fragile if the class is reused elsewhere without full context.
- Link pseudo-class order matters due to equal specificity + source order: LVHA mnemonic = :link, :visited, :hover, :active ("LoVe/HAte").
- "Cascaded value": at most one final value per property per element after the cascade runs independently for every property of every element.
- Inheritance ≠ cascade. Only text-related props inherit by default: color, font, font-family, font-size, font-weight, font-variant, font-style, line-height, letter-spacing, text-align, text-indent, text-transform, white-space, word-spacing; plus list-style*, border-collapse, border-spacing.
- TRICK: set font-family (and other text defaults) once on <body>; let it inherit down instead of repeating on every element.
- `inherit` keyword: force a property to take its parent's computed value even if it wouldn't normally inherit (e.g. a link color inheriting the surrounding footer text color instead of the global link color) — keeps styles in sync if the parent changes.
- `initial` keyword: resets a property to its CSS-spec default (not "auto", not the browser stylesheet default). E.g. color:initial → usually black. display:initial → inline (NOT block), a common gotcha.
- Avoid the `font` shorthand except on <body>/global reset — it silently resets font-style, font-variant, font-weight, font-stretch, line-height to "normal" for every omitted sub-property, clobbering a bold weight set elsewhere. This applies to ALL shorthands: omitted longhand values are NOT left alone, they're reset to initial.
- Shorthand ordering:
  - 4-side box properties (margin, padding, border-width, border-color...) use CLOCKWISE order starting at top: mnemonic TRouBLe = Top Right Bottom Left. Truncated forms: 1 value=all sides; 2=vert,horiz; 3=top,horiz(L=R),bottom; 4=T R B L.
  - 2-value "Cartesian" properties (background-position, box-shadow, text-shadow offsets) go horizontal-then-vertical (x, y) — opposite order from the 4-value box mnemonic. Mental model: "clock" for 4-value box props, "Cartesian grid (x,y)" for 2-value offset props.
- Use browser DevTools element inspector to see cascaded/overridden/inherited values directly — fastest way to debug "why isn't my rule applying."
- If building a distributable JS component: don't apply inline styles via JS (forces consumers into !important wars); ship a stylesheet and toggle classes with JS instead.

---

- Absolute unit conversions: 1in = 25.4mm = 2.54cm = 6pc = 72pt = 96px. Browser default font-size = 16px ("medium" keyword).
- 1em = current element's font-size for non-font properties (padding, border-radius, width...). For font-size itself, 1em = INHERITED font-size (can't be relative to itself).
- TIP formula: desired-px / inherited-px = em value. E.g. want 10px inside a 12px parent → 10/12 = 0.833em.
- Order of computation on one element: font-size is computed FIRST, then other em-based properties on that same element use the newly computed font-size — so `font-size:1.2em; padding:1.2em;` do NOT give equal pixel results.
- "Shrinking/growing font" bug: em-based font-size compounds across nested elements of the same type (e.g. `ul{font-size:.8em}` nested lists keep shrinking 0.8× per level). Fix (imperfect): add `ul ul{font-size:1em}` to reset nested levels — or better, avoid ems for repeatedly-nested font sizes.
- REM ("root em") = always relative to the root (<html>) font-size, immune to nesting compounding. `:root` pseudo-class ≡ `html` selector but with class-level specificity.
- Recommended defaults (author's own convention): rems for font-size, px for borders (crisp 1px lines), ems for padding/margin/border-radius (so they scale with local font-size), percentages for container widths.
- ACCESSIBILITY: always size fonts with relative units (rem/em/%), never px — a user's browser "default font size" setting only rescales relative units, not absolute px values. (Zoom rescales everything regardless.)
- ANTIPATTERN: setting `html{font-size:62.5%}` (or .625em) to make "10px=1rem" mental math easier. Downsides: forces you to override the tiny default size almost everywhere (more code, more duplication), and you're still secretly thinking in pixels instead of relative "fuzzy" sizing. Better: set the root font-size directly to your real intended base size (e.g. 14px → 0.875em) and let everything else cascade/inherit from it, only touching pixels rarely (initial base value, and per-property overrides like headings).
- Whole-page responsive scaling trick: set root font-size smaller for mobile and larger inside `@media (min-width: ...)` blocks targeting :root only. If every other measurement on the page is expressed in em/rem, the entire page rescales fluidly from just 2-3 media queries instead of dozens scattered through the stylesheet.
- Per-component resizing trick: give a component wrapper `font-size: 1rem` (a "local anchor"), define all its internal sizes in `em` relative to that, then to produce a "large" variant just override the single wrapper font-size (e.g. `.panel.large{font-size:1.2rem}`) — the whole component scales as a unit.
- Viewport units: vw/vh = 1% of viewport width/height; vmin = 1% of the SMALLER dimension (orientation-safe sizing, e.g. `width/height:90vmin` for a square that always fits); vmax = 1% of the larger dimension (poor browser support historically).
- `font-size: Nvw` scales smoothly with viewport but has no min/max — gets unreadably small on phones and too large on big screens.
- Fluid typography formula: combine a fixed em minimum with a vw scalar via calc(): `font-size: calc(0.5em + 1vw)` — gives a smooth min-to-scaling curve without hardcoded breakpoints, a big chunk of a responsive strategy in one line. (Modern equivalent: CSS `clamp()`.)
- calc() requires whitespace around + and - (not * and /): always write `calc(1em + 10px)`.
- Unitless numbers are valid for line-height, z-index, font-weight (400=normal,700=bold), and 0-length values (0 needs no unit anywhere a length is expected, but NOT for angles/time).
- CRITICAL: prefer UNITLESS line-height (e.g. `line-height: 1.2`) over a value with units. A unitless number is inherited as the raw ratio and RECOMPUTED per descendant's own font-size. A unit-based line-height (`1.2em`) is inherited as its already-computed pixel value, which then causes overlapping text if a descendant has a larger font-size than the ancestor.
- Custom properties (CSS variables): declared as `--name: value;` inside a rule (commonly `:root{}` for page-wide), read with `var(--name, fallback)`. They cascade AND inherit like any other property, so redefining `--main-bg` inside a `.dark` container scopes new values just to that subtree — enables "theming" a nested region without extra classes on children. Invalid var() resolution → property resets to its initial value (not silently ignored). Provide a plain fallback declaration before the var() one for old-browser support since unsupported var() are ignored entirely, leaving the previous declaration in place.
- Custom properties are readable/writable at runtime via JS (`getComputedStyle(el).getPropertyValue('--x')`, `el.style.setProperty('--x','val')`) enabling live re-theming — genuinely different from Sass/Less variables, which are compile-time only.

---

- Universal border-box fix (put at top of EVERY new stylesheet):
  ```css
  :root { box-sizing: border-box; }
  *, ::before, ::after { box-sizing: inherit; }
  ```
  Using `inherit` (not setting border-box directly on `*`) lets a third-party component opt back into content-box by setting `box-sizing: content-box` once on its top-level wrapper and letting children inherit it — impossible if you'd used `box-sizing: border-box` directly on `*`.
- Avoid "magic numbers" (e.g. a hand-tweaked 26% found by trial and error) — if you can't explain where a number came from, it'll break under different conditions (screen sizes). Prefer `calc()` to express the real relationship, e.g. `width: calc(30% - 3em)` for a column that must subtract its own gutter/padding.
- NEVER set explicit height on an element unless there's no alternative — normal flow is built for constrained width + organic height; forcing height risks overflow. Prefer min-height/max-height (and min-width/max-width) to bound without fully fixing size.
- overflow: visible (default, content spills out) | hidden (clipped) | scroll (always show scrollbars, can double-scrollbar oddly) | auto (scrollbars only when needed — usually the best choice). Avoid nested scrollable regions where possible — they trap the mouse wheel and frustrate users.
- Percentage heights only resolve if the PARENT has an explicit height (otherwise browser ignores the declaration — circular dependency). Use vh units or flex/grid instead of percentage heights to fill viewport or match sibling height.
- Equal-height columns: don't hardcode a height. Use `display:flex` on the container (children equal-height by default) — simplest modern method, no extra wrapper needed. Older technique: `display:table`/`table-cell` on parent/children (table-cell can't take margins — use border-spacing on the table + a negative margin on an outer wrapper to correct outer edge alignment). TIP: prefer flexbox over table layout unless you must support IE9-.
- vertical-align:middle does NOTHING on ordinary block elements — it only affects inline or table-cell elements (or items next to them on the same line). This is one of the most common vertical-centering gotchas.
- Vertical centering decision list (try in order): (1) equal top/bottom padding on a natural-height container — simplest, works for any content type; (2) display:table-cell + vertical-align:middle if you need a fixed-height container; (3) flexbox (`align-items:center`) if you don't need old-IE support; (4) tall unitless line-height equal to desired container height, for single-line inline content; (5) absolute positioning with known height/width; (6) absolute positioning + transform(translate(-50%,-50%)) when the content's own height is unknown — treat (5)/(6) as last resorts.
- Negative margins: on left/top they SHIFT the element itself (can overlap a preceding element — watch for rendering something unclickable underneath). On right/bottom they pull in the FOLLOWING sibling instead of moving the element itself. A negative left+right margin on a width:auto block stretches it wider than its parent (used to make a nested container bleed to the full page width despite outer padding).
- MARGIN COLLAPSING: adjacent (vertically touching) top/bottom margins combine into ONE margin equal to the LARGER of the two, not their sum — behaves like a "personal space bubble." Applies through empty intermediate wrapper divs too (chained collapsing), and can leak a child's margin outside its own parent container if nothing stops it. Left/right margins never collapse.
  - Ways to stop margin collapsing through a container boundary: give the container `overflow: auto` (or any non-visible value) — usually the least invasive fix; add a border or padding between the two margins; the element is floated, is an inline-block, or has position:absolute/fixed; the layout is flex or grid (flex/grid items never collapse margins with each other); table-cell/table-row elements have no margin at all so nothing to collapse.
- Gutter-between-columns pattern: subtract the gutter amount from one column's width via calc() and add it as margin (e.g. `width: calc(30% - 1.5em); margin-left: 1.5em;`) — prefer an em-based gutter (via calc) over a pure-percentage margin for a value that's independent of container width and self-documenting in code.
- "Lobotomized owl" selector — `* + *` (optionally scoped, e.g. `body * + *`) — applies a margin (e.g. margin-top) to every element that has a preceding sibling, i.e. automatically spaces stacked items without ever margining the FIRST child. Removes the need to special-case "don't add a top margin to the first item" as content changes over time. Tradeoff: you'll need to override/reset it in places using side-by-side layouts (flex/grid rows), and it's risky to retrofit onto an existing large stylesheet.
- Fine-grained alternative to lobotomized owl for a specific repeated pattern: adjacent-sibling combinator scoped to a class, e.g. `.button-link + .button-link { margin-top: 1.5em; }` — only spaces items after the first of that specific type, avoiding uneven padding+margin stacking at the top of a container.
- Modern browsers handle the universal selector (`*`) efficiently — the old IE6-era performance worry about `*` no longer applies; using it (as in the lobotomized owl) can even reduce total selector count.
