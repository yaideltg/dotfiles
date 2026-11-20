# CSS Selectors Quick Reference

Condensed from *CSS in Depth*, Appendix A. Load this when writing or reviewing complex selectors, or when unsure of a selector's exact specificity/behavior.

## Specificity by selector type
| Selector | Specificity |
|---|---|
| Type/tag (`div`, `p`) | 0,0,1 |
| Class (`.foo`), pseudo-class (`:hover`), attribute (`[type=x]`) | 0,1,0 |
| ID (`#foo`) | 1,0,0 |
| Pseudo-element (`::before`) | 0,0,1 (same as type) |
| Universal (`*`), combinators (`>`,`+`,`~`) | 0,0,0 (no effect) |
| Inline `style=""` | beats all selectors (effectively 1,0,0,0) |
| `!important` | own higher-priority origin, beats normal specificity entirely |

## Combinators
- ` ` (space) — descendant, any depth: `.nav li`
- `>` — direct child only: `.nav > li`
- `+` — adjacent sibling (immediately follows): `h2 + p`
- `~` — general sibling (any later sibling, same parent): `li.active ~ li`
- Compound (no space): `h1.page-header` — must match ALL parts

## Useful pseudo-classes
- Structural: `:first-child`, `:last-child`, `:only-child`, `:nth-child(An+B)`, `:nth-last-child()`, `:first-of-type`, `:last-of-type`, `:only-of-type`, `:nth-of-type()`, `:nth-last-of-type()`
  - `:nth-child(n)` = every element; `(2n)` = even; `(2n+1)`/`(odd)` = odd; `(3n+2)` = every 3rd starting at 2; `(n+4)` = 4th onward; `(-n+4)` = first four only.
- `:not(<simple-selector>)` — negation (can't contain another `:not()`, can't target ancestors)
- `:empty` — no children (whitespace text nodes still count as a child, so this rarely matches elements with visible whitespace)
- `:focus`, `:hover`, `:root`
- Form states: `:disabled`, `:enabled`, `:checked`, `:invalid`, `:valid`, `:required`, `:optional` (some are Selectors Level 4 — check support)

## Pseudo-elements (double-colon, `::`)
- `::before` / `::after` — inject generated content as first/last child; require `content:` to render; inline by default
- `::first-letter`, `::first-line`
- `::selection` — styles user-highlighted text (only a handful of properties apply: color, background-color, cursor, text-decoration)

## Attribute selectors
- `[attr]` — has the attribute at all
- `[attr="value"]` — exact match
- `[attr^="value"]` — starts with
- `[attr$="value"]` — ends with
- `[attr*="value"]` — contains substring (careful: `[class*="column-"]` also matches `column-header` etc.)
- `[attr~="value"]` — one word in a space-separated list matches exactly
- `[attr|="value"]` — exact match, or match followed by a hyphen (e.g. language subcodes: `[lang|="es"]` matches `es` and `es-MX`)
- Case-insensitive modifier (Level 4, patchy support): `[value="search" i]` — provide a case-sensitive fallback too
