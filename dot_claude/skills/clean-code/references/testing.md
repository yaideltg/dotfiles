# Tests

Tests are production code. A messy, coupled test suite rots just like
messy production code does — and once it rots, people stop trusting
it, then stop running it, then stop writing it. Treat every rule in
this skill (naming, small functions, no duplication) as applying to
test code too.

## F.I.R.S.T.

- **Fast** — slow tests don't get run often, and problems caught late
  are more expensive to fix. Treat test speed as a design constraint,
  not an afterthought.
- **Independent / Isolated** — one test's setup should never depend on
  another test having run first. Tests should be safely runnable in
  any order, and in isolation. A chain of dependent tests turns one
  failure into a confusing cascade.
- **Repeatable** — a test must produce the same result in any
  environment (CI, a laptop, offline). A test that only passes in one
  environment stops being trustworthy evidence of correctness.
- **Self-validating** — a test's outcome is a boolean (pass/fail), not
  something a human has to read a log or diff to interpret.
- **Timely** — write the test alongside the code it covers, not long
  after. Code written without a test in mind is often awkward to test
  after the fact; writing the test first (or concurrently) naturally
  pushes the production code toward a more testable shape.

## Test design mirrors production design

The same coupling concerns apply: if a single, reasonable change to
production code (e.g. a function signature) forces edits across
hundreds of tests, the test suite itself is poorly designed — probably
too tightly coupled to implementation detail rather than to observable
behavior. Minimize that coupling the same way you would in production
code: extract shared setup, assert on behavior/outcomes rather than
internal structure, and give tests names and structure that make the
*intent* of each test obvious without reading its body closely.

## Acceptance-level thinking

Where practical, frame a new feature's behavior as concrete
input → action → expected-output scenarios (the Arrange/Act/Assert or
Given/When/Then shape) *before* or *while* writing the implementation.
This isn't just a testing technique — it's a way of pinning down
ambiguity in a requirement before code gets written against a fuzzy
version of it. See `ai-generated-code.md` for why this matters
specifically when the code is being generated from a natural-language
prompt.

## Practical defaults when writing or changing behavior

- If you add or change a public function's behavior, add or update a
  test that pins down the new behavior — don't leave it to be covered
  "later."
- Prefer one clear assertion/concept per test case over one giant test
  that checks many unrelated things — a failure should point precisely
  at what broke.
- Don't assert on incidental implementation details (e.g. exact
  internal call counts to a helper) when asserting on the observable
  outcome would do — that couples the test to *how* the code works
  rather than *what* it does, and breaks tests on refactors that don't
  change behavior.
