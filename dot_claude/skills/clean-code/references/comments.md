# Comments

"Don't comment bad code — rewrite it." A comment is, at best, a
necessary admission that the code alone couldn't express the intent.
It's not something to be proud of adding — every comment is a small
failure of the code (or of the author) to be self-explanatory, even
when that failure is sometimes unavoidable.

This does **not** mean "never write comments." It means: before
writing one, ask whether a better name, an extracted function, or a
named variable/constant would make the comment unnecessary. If it
would, do that instead.

```
// Check to see if the employee is eligible for full benefits
if ((employee.flags & HOURLY_FLAG) && (employee.age > 65))
```
vs.
```
if (employee.isEligibleForFullBenefits())
```
The second needs no comment because the code says it directly.

## Comments worth keeping

- **Legal/license headers** — required, usually collapsed by the IDE.
- **Explanation of intent** — *why* a non-obvious decision was made
  (e.g. why a comparison returns 1 in a particular branch, why a race
  condition is being deliberately provoked in a test).
- **Warning of consequences** — e.g. why a test is disabled, or why a
  particular call must not be "optimized away."
- **Clarification** — translating an opaque return value or a regex
  into something readable, especially for code you don't control
  (a third-party library, a fixed data format).
- **Amplification** — flagging that a seemingly trivial line (a
  `.trim()`, a specific ordering) is actually load-bearing.
- **Public API docs** (Javadoc-style) — genuinely useful for code
  meant to be consumed by people who can't easily read the
  implementation.

## Comments to avoid / delete on sight

- **Mumbling** — a vague comment ("no properties file means defaults
  are loaded") that doesn't actually explain what happens or why;
  worse than no comment because it implies an explanation exists.
- **Redundant comments** — a comment that just restates the code
  (`// returns the day of the month` above `getDayOfMonth()`), or a
  header comment that's harder to parse than the function itself.
- **Misleading comments** — comments that describe behavior slightly
  differently than what the code actually does. These are actively
  dangerous, not just useless.
- **Mandated comments** — a policy requiring every function/variable
  to have a comment produces noise (`/** The name. */` above
  `private String name;`) that trains readers to skip all comments,
  including the ones that matter.
- **Journal/changelog comments at the top of a file** — that's what
  source control history is for.
- **Noise comments** venting frustration (`//Give me a break!`) —
  redirect that energy into fixing the code's structure instead.
- **TODO comments left checked in** — either do the thing, remove the
  need for it, or track it in a real backlog/issue tracker. A TODO
  that's been sitting for months is a lie about intent.
- **Position markers / banners** (`// Actions ////////`) — rarely earn
  their clutter; overused, they become background noise.
- **Attribution/byline comments** (`/* Added by Rick */`) — source
  control already tracks this, and it goes stale.
- **Commented-out code** — never check this in. Nobody will feel safe
  deleting it later, so it just accumulates. Delete it; source control
  remembers it if it's ever needed again.
- **Nonlocal information** — a comment on one function describing
  behavior that actually lives elsewhere in the system (e.g. a default
  value the function doesn't control) will drift out of sync.
- **Too much information** — don't dump a spec/RFC excerpt into a
  comment; link to it if it's genuinely needed.

## The test

Ask: if I deleted this comment, would a careful reader of the code
lose real information they couldn't get any other way? If yes, keep
it (and keep it accurate). If no — if it's restating the code, coping
for a bad name, or explaining something you could name instead — fix
the code and drop the comment.
