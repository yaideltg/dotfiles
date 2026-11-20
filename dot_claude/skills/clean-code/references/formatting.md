# Formatting

Formatting is about communication first. It's not something to treat
religiously (don't die on a hill about brace style), but it's not
something to ignore either — the visual structure of code is the first
thing a reader perceives, before they've parsed a single expression.

## Vertical formatting

- **File/module size**: smaller is generally better. Very rough rule
  of thumb from the book's own codebases: most files well under ~200
  lines, an upper bound around ~500 before you should suspect the file
  is doing too much. Treat this as a smell threshold, not a hard cap —
  language and framework norms vary a lot.
- **Vertical openness**: blank lines between distinct concepts
  (imports, each function, logical sections within a function) act as
  visual cues — the eye is drawn to the first line after a blank one.
  Don't remove them to save space.
- **Vertical density**: lines that are tightly related (e.g. two field
  declarations that are always used together) should sit close
  together, with no comments or blank lines splitting them up if that
  hurts the "eye-full" comprehension of the group.
- **Vertical distance / dependent functions**: if function A calls
  function B, put B close to A — ideally right after it — so the
  reader doesn't have to hunt. Read top-to-bottom like a newspaper: the
  most important/abstract logic first, details further down (the
  **stepdown rule**).
- **Variable declarations**: as close as possible to first use. Loop
  control variables declared in the loop statement itself. Instance
  variables/fields belong in one predictable, well-known place (top or
  bottom of the class, consistently) — the important thing is *where
  everyone expects to look*, more than which convention is chosen.
- **Conceptual affinity**: group functions that do similar things
  (e.g. `assertTrue`/`assertFalse` variants) near each other even if
  they don't call one another.

## Horizontal formatting

- Prefer short lines; ~80–120 characters is a reasonable band
  depending on team/tooling. Avoid forcing horizontal scrolling.
- Use whitespace to show precedence and grouping: spaces around
  low-precedence operators (`+`, `-` in a mixed expression), none
  around high-precedence ones or between a function name and its
  opening parenthesis (`f(x)`, not `f (x)`).
- Don't manually align columns of declarations or assignments
  (padding variable names/values to line up visually) — it draws the
  eye to the wrong thing (the aligned column, not the actual content)
  and doesn't survive refactors. If a block of declarations feels like
  it "needs" alignment because it's so long, that's usually a sign the
  class/function itself should be split up, not a sign to align it.
- **Indentation** is not optional or negotiable, even for one-line
  `if`/`while` bodies or short functions — collapsing braces onto one
  line to save vertical space consistently costs more readability than
  it saves. Prefer the fully indented form; a one-line getter
  (`public int getCount() { return count; }`) is one of the few
  reasonable exceptions.

## Team rules

If a team or project has already agreed on formatting rules — brace
style, indent width, import order, a linter/formatter config — those
rules win over any personal preference described here, including
anything in this skill. The value of formatting comes from
*consistency across the codebase*, not from any one rule being
objectively best. When in doubt, run the project's formatter/linter
rather than hand-formatting to match a personal style.
