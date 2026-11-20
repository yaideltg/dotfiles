---
name: clean-code
description: Write and review code (any language) following the Clean Code principles from Robert C. Martin's book (naming, small functions, comments, formatting, error handling, objects vs. data structures, class design, SOLID, tests). Use this whenever writing new code, editing existing code, refactoring, or reviewing/critiquing code someone else wrote — not just when the user says "clean code" explicitly. Also use it when the user asks for a code review, asks "how should I structure this", complains that code is messy/hard to follow, or asks you to name something, split up a function, reduce duplication, or simplify a class. Applies across languages (Java, Python, JS/TS, Go, C#, Ruby, C++, etc.) — translate the idioms to whatever language is in play.
---

# Clean Code

This skill encodes the practical rules from *Clean Code: A Handbook of
Agile Software Craftsmanship* (Robert C. Martin, with Jeff Langr and
others), 2nd edition. The goal isn't ceremony — it's writing code that
the next reader (often you, in six months, or another instance of
Claude) can understand without a guided tour. Apply this by default to
any code you write or touch, not only when explicitly asked to "clean
up" something.

The core thesis of the book: **you read code far more often than you
write it**, so every local decision should optimize for the reader.
When a rule below and "getting it working fast" conflict, remember
that the readability of the code outlives its first working version.

## How to use this skill

1. **When writing new code**, apply the checklist below as you go —
   don't write it messy and plan to clean it later. Small functions,
   good names, and one level of abstraction per function are cheaper
   to do from the start than to retrofit.
2. **When editing existing code**, follow the Boy Scout Rule: leave the
   module a little cleaner than you found it. You don't need to
   refactor the whole file to fix one bug, but don't add a new
   violation next to the ones you found.
3. **When reviewing or critiquing code**, use the checklist and the
   reference files to ground your feedback in specific, named
   principles (e.g. "this violates SRP because…") rather than vague
   taste. Prioritize: correctness and behavior first, then
   comprehensibility (naming, function size, duplication), then
   structural/architectural concerns (SOLID, coupling) — don't drown a
   review in style nits if the function is also wrong.
4. **Match the codebase you're in.** If a project has established
   conventions (naming style, line length, a formatter config), those
   team rules win over the personal defaults below (see "Team Rules"
   in `references/formatting.md`). Clean Code is about consistency and
   readability, not about a single sacred style.
5. **Don't cite the book to the user unprompted.** Apply these
   principles silently, the way any good engineer would — no need to
   annotate code with "// Clean Code says…" or narrate which rule
   you're following, unless the user is asking to *learn* the
   principles or asks why you made a particular choice.

## The core checklist

Before considering a piece of code done, run through this. Full
rationale and examples for each item live in the reference files
linked alongside it.

**Naming** (`references/naming.md`)
- Names reveal intent — no `d`, `tmp`, `data2` without a very short,
  obvious scope. A reader shouldn't need a comment to know what a name
  means.
- One word per concept across the codebase (don't mix `fetch`/`get`/
  `retrieve` for the same idea).
- Name length is proportional to scope for variables (short scope →
  short name is fine) and *inversely* proportional to scope for
  functions/classes (a widely-used function can have a short name; a
  private helper called from one place can have a long, precise one).
- No encodings (no Hungarian notation, no `I` prefix on interfaces, no
  `m_` prefixes) — let the type system and IDE do that job.
- Classes/objects are nouns; functions/methods are verbs.

**Functions** (`references/functions.md`)
- Small. If you can extract a well-named chunk out of a function,
  usually do it.
- Do one thing, at one level of abstraction. Don't mix "loop over all
  customers" with "compute tax for one line item" in the same
  function body.
- Prefer few arguments (0–3). More than three is a signal to bundle
  related arguments into an object, or reconsider the design.
- No boolean "flag" arguments that silently pick between two behaviors
  — split into two functions instead.
- No output arguments; return values (or return an object) instead of
  mutating an argument to produce a result, when the language allows it.
- Functions should either *do* something (command) or *answer*
  something (query), not both — command/query separation, applied
  where practical.

**Comments** (`references/comments.md`)
- A comment is a fallback for when the code itself can't express
  intent — not a substitute for a better name or a smaller function.
  Prefer renaming or extracting a function over adding an explanatory
  comment.
- Never leave commented-out code, changelog/journal comments, or
  comments that just restate what the code already says.
- Comments that explain *why* (a non-obvious business rule, a warning
  about consequences, a rationale for an unusual approach) are
  valuable and worth keeping.

**Formatting** (`references/formatting.md`)
- Keep files and functions short; group related concepts with blank
  lines, keep tightly related lines dense.
- Variables declared close to where they're used; instance
  variables/fields in one predictable place.
- If function A calls function B, put B right after A when the
  language/file layout allows it — code should read top-to-bottom like
  a narrative (the "stepdown rule").
- Follow the file's or project's existing formatting/linter config
  over personal preference.

**Error handling & control flow** (`references/functions.md`)
- Prefer exceptions (or a language's idiomatic error type, e.g. Go's
  `error`, Rust's `Result`) over sentinel error codes and deeply
  nested `if` checks.
- Extract `try/catch` bodies into their own functions — a function
  that handles errors should do only that.
- Don't repeat yourself (DRY) — but judge duplication by whether the
  duplicated lines are likely to change together (essential
  duplication, worth extracting) or change independently for different
  reasons/actors (accidental duplication, better left alone — see SRP).
- Avoid scattering the same `switch`/`if-else` type-check across many
  functions; bury it once behind polymorphism or a factory, at the
  boundary of the system.

**Objects, data structures & classes**
(`references/objects-and-classes.md`)
- Decide deliberately whether something is an *object* (hides data,
  exposes behavior — easy to add new types, hard to add new
  operations) or a *data structure* (exposes data, no behavior — easy
  to add new operations, hard to add new types). Don't build hybrids
  that are half of each.
- Don't reflexively add getters/setters for every field; expose
  abstractions, not implementation.
- Law of Demeter: a method should only talk to itself, its own fields,
  things it created, or things passed to it — avoid `a.getB().getC().getD()`
  chains ("train wrecks").
- Classes should be small and cohesive: one reason to change (Single
  Responsibility Principle). If a class's methods serve unrelated
  actors/stakeholders, split it.

**Design principles / SOLID** (`references/solid-and-design.md`)
- SRP, Open-Closed, Liskov Substitution, Interface Segregation,
  Dependency Inversion — use these as a vocabulary for *why* a design
  is stiff or fragile, not as a checklist to satisfy for its own sake.
- Depend on abstractions for the volatile, frequently-changing parts
  of a system; concrete, stable dependencies (standard library,
  well-established platform APIs) are fine to depend on directly.
- Favor simple design: it must work (pass its tests), reveal its
  intent clearly, have no duplication, and have no more
  classes/methods than needed — in roughly that priority order.

**Tests** (`references/testing.md`)
- Tests are real code: keep them clean, one clear assertion/concept
  per test, no duplication that will make future changes ripple across
  dozens of tests.
- F.I.R.S.T.: Fast, Independent/Isolated, Repeatable (any environment),
  Self-validating (pass/fail, not "read the log"), Timely (written
  alongside the production code, not long after).
- Write tests when you write or change behavior, not as an afterthought
  — this is as true for an AI-assisted change as for a human one.

## Working with the grain of AI-assisted coding

The book's chapter on AI-generated code (Ch. 17) makes a point that
applies directly to how you should operate: **natural-language
instructions are ambiguous, and code generated from an ambiguous spec
is only accidentally correct.** The book's proposed fix is to
"overload" intent — state what's wanted in more than one way so errors
in one statement get caught by the other. In practice, that means:

- When a request is underspecified (edge cases, exact behavior on bad
  input, what a name like "active" means), make a reasonable
  assumption explicit rather than silently picking one — a one-line
  assumption beats a silently-wrong implementation.
- Treat tests as the second, formal statement of intent. When you
  write new behavior, write or update the tests that pin it down —
  the test is the "given/when/then" that keeps the code and the
  requirement in sync, and catches drift the next time the code (or a
  future prompt) changes it.
- Don't regenerate large working sections from scratch to satisfy a
  small new requirement; make the smallest change that satisfies it,
  the way the Boy Scout Rule and "small functions" above already
  recommend. Wholesale regeneration is exactly the failure mode the
  chapter warns about — it reintroduces risk into code that already
  worked.

## When these rules trade off against each other

These are heuristics, not laws — the book is explicit about this
throughout. A few common tensions and how to resolve them:

- **Small functions vs. entanglement**: decomposing a large function
  can create small functions that only make sense read together. That
  cost is acceptable as long as each step is one level of abstraction
  below its caller and the lower-level functions are positioned right
  after their caller (see `references/functions.md`).
- **DRY vs. accidental duplication**: don't merge two similar-looking
  blocks just because they're similar, if they belong to different
  actors/reasons-to-change — that couples things that should stay
  independent (see SRP in `references/solid-and-design.md`).
- **OO polymorphism vs. a plain switch/if-else**: a switch statement is
  fine, even preferable, when new *behaviors* are added often but new
  *types* rarely; polymorphism is preferable when the opposite is true
  (see `references/objects-and-classes.md`).
- **Strict rules vs. a codebase's existing style**: match the
  surrounding code's conventions first; introduce a cleaner pattern
  incrementally rather than as an unrelated drive-by change.

Read the linked reference file when you need the fuller rationale,
more examples, or you're making a judgment call at the edge of one of
these heuristics — the summaries above are meant to be enough for the
common case.
