---
name: css-in-depth
description: Deep CSS engineering reference distilled from the book "CSS in Depth" (Keith J. Grant) — cascade/specificity mechanics, the box model, flexbox/grid/positioning layout, responsive design, modular CSS architecture (BEM), color/spacing/typography precision, and performant transitions/animations. Use this whenever writing, reviewing, or debugging CSS: laying out a page, fixing a specificity or margin-collapsing bug, choosing between flexbox and grid, structuring a stylesheet for a multi-component project, matching a design mockup pixel-for-pixel, or adding hover/transition/animation effects. Combine with the frontend-design skill (aesthetic/visual-identity decisions) and any pptx/docx/frontend-build skills — this skill supplies the CSS correctness, performance, and architecture know-how those don't cover. Prefer this over answering CSS questions from general memory alone.
---

# CSS in Depth

Engineering-grade CSS knowledge: the mechanics, gotchas, and battle-tested patterns that separate CSS that *happens to work* from CSS that is predictable, maintainable, and fast. This is a companion to `frontend-design` (which governs taste — palettes, type pairing, layout concepts) — use this skill for whether the CSS is *correct and well-built*.

## How to use this skill

1. Skim the **Non-negotiable defaults** below and apply them to any new stylesheet or component without being asked.
2. When a task calls for depth on a specific topic, read the matching file in `reference/` — each is self-contained and written for direct application, not narrative reading. Don't load a reference file "just in case"; load it when the task actually touches that area.
3. Apply fixes/patterns directly in the code you write. Don't lecture the user with the reference material — use it to make better CSS, and only surface the *reasoning* when it explains a non-obvious choice (e.g. "using `transform` here instead of `top` for smoother animation").

| Reference file | Load when the task involves... |
|---|---|
| `reference/fundamentals.md` | A rule not applying / being overridden unexpectedly; choosing px vs. em vs. rem; unexpected spacing from margin collapsing; box-sizing weirdness; CSS custom properties |
| `reference/layout.md` | Building any page/component layout; choosing float vs. flexbox vs. grid; centering things; equal-height columns; dropdowns/modals/tooltips (positioning + z-index); responsive/mobile-first breakpoints; responsive images |
| `reference/architecture.md` | A stylesheet with more than a handful of components; naming classes; avoiding specificity creep across a growing project; building a design-system/component library |
| `reference/visual-design.md` | Implementing a supplied mockup precisely; gradients/shadows/blend modes; picking or deriving colors (HSL); WCAG contrast; web fonts and font-loading performance |
| `reference/motion-performance.md` | Hover states, transitions, or keyframe animations; anything that feels janky/slow; 3D effects |
| `reference/selectors-reference.md` | A quick specificity/selector-syntax lookup (combinators, `:nth-child` formulas, attribute selectors) |
| `reference/preprocessors.md` | The project uses (or is deciding whether to adopt) Sass/Less/PostCSS |

## Non-negotiable defaults

Apply these to essentially every new stylesheet unless the project's existing conventions clearly say otherwise.

**Box sizing reset** — put this at the top of every new stylesheet:
```css
:root { box-sizing: border-box; }
*, ::before, ::after { box-sizing: inherit; }
```
Using `inherit` (not `border-box` directly on `*`) lets a third-party component opt back into `content-box` on just its own root. See `fundamentals.md`.

**Selector discipline** — never write a selector that reaches into a component from the outside (`.page-header .dropdown`) to change its look; add a modifier class to the component instead (`.dropdown--dark`). Avoid ID selectors and `!important` in ordinary rules (both make future overrides progressively harder) — the one sanctioned use of `!important` is tiny, single-purpose utility classes (`.hidden { display:none !important; }`). See `architecture.md`.

**Units** — rems for font-size, px for hairline borders, ems for padding/margin/border-radius that should scale with local font-size, percentages for fluid container widths. Always size text in relative units (never px) for accessibility. Unitless `line-height` only — never `1.4em`. See `fundamentals.md`.

**Layout method** — reach for flexbox for one-dimensional alignment (a row/column of related items), grid for two-dimensional layout (the page skeleton, anything where items must align across rows *and* columns), and don't use position/floats for layout that flexbox or grid would make simpler. Never set an explicit `height` on an element if content can be allowed to size it naturally.

**Mobile-first & fluid** — write unqualified base styles for the smallest viewport, layer `min-width` media queries upward; use em-based breakpoints, not px; never fix a container width in a way that forces horizontal scroll on a narrow screen; add `img { max-width: 100%; }` as a blanket safety net.

**Animation performance** — animate only `transform` and `opacity` when at all possible; both can skip layout and often skip main-thread paint entirely (GPU-composited), unlike `top`/`left`/`width`/`height`/margins, which force expensive reflow. See `motion-performance.md`.

**Accessibility baseline** — visible `:focus` state on every interactive element (never `outline: none` without a real replacement); WCAG-AA contrast (4.5:1 body text, 3:1 large text) at minimum; respect that hover-only interactions don't work for touch/keyboard users — pair `:hover` with `:focus`.

## Cross-cutting judgment calls

A few decisions recur across almost every project; the reference files cover the mechanics, but the call itself is worth stating up front:

- **"It depends" is often the correct answer.** CSS frequently offers multiple valid solutions to the same problem (e.g. four different ways to win a specificity fight — see `fundamentals.md`); the right one depends on whether the pattern needs to generalize elsewhere on the site. Default to the option that keeps specificity lowest and the component most reusable.
- **Modular, component-scoped CSS wins as a project grows.** A single reusable `.button` styled once beats five near-duplicate button rules scattered by page — this is also what makes visual contrast/hierarchy (see `visual-design.md`) actually work, since contrast depends on consistent patterns existing everywhere else.
- **Prefer the platform.** Native CSS custom properties, `calc()`, grid, and `clamp()`-style fluid sizing now cover most of what preprocessors and JS layout hacks used to be needed for — reach for a preprocessor (`preprocessors.md`) only when the project already has one or genuinely needs compile-time features.
