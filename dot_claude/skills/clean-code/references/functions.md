# Functions

Functions are the first line of organization in any program. Small,
well-named, single-purpose functions are the single highest-leverage
habit in this whole skill.

## Small, and one thing

- Aim small — a handful of lines, not dozens. If an `if`/`else`/`while`
  body is more than a line or two, extract it into a well-named
  function call. This keeps nesting shallow (rarely more than one or
  two levels) and makes the outer function read like prose:
  `if (employee.shouldBePaidToday()) employee.pay();`
- **One level of abstraction per function.** Don't mix a high-level
  concept ("loop over rentals") with a mid-level one ("switch on movie
  type") and a low-level one ("increment a counter") in the same
  function body. If you notice mixed levels, extract the lower-level
  parts out.
- **The Stepdown Rule**: organize functions so the code reads top to
  bottom, one level of abstraction lower at each step — the top
  function orchestrates, and each function below it either does the
  actual small thing or calls further down. First make it work, then
  refactor into this shape ("make it work, then make it right").
- Some resulting entanglement between adjacent small functions
  (understanding one requires understanding its neighbor) is an
  acceptable cost of decomposition, as long as the caller/callee
  ordering and abstraction levels stay clean. Don't use "they're
  entangled" as a reason to keep one big function instead.

## Naming a function well

A good function name is both **descriptive** (a verb or verb phrase
that says what it does, one level more abstract than its
implementation — `average(a, b)`, not `addAtoBandDivideBy2`) and
**convenient** (short enough not to be a burden at its call sites).
Balance the two based on scope, same as with variables: widely-called
functions get short names; narrow, rarely-called private helpers can
and should be longer and more specific.

## Arguments

- Fewer is better. Zero and one are easiest to read; three is a
  reasonable practical ceiling; beyond that, look for a way to group
  related arguments into an object or config/params struct — if
  several values are cohesive enough to always travel together as
  arguments, they're probably a type that doesn't exist yet.
- **No boolean flag arguments.** `getMonths(false)` tells the reader
  nothing at the call site. Split into two functions (`getLongMonthNames()`
  / `getShortMonthNames()`) instead. (Exception: a genuine
  `setFlag(boolean)` toggle on an object is fine.)
- **Avoid output arguments** (mutating a passed-in reference/pointer to
  produce a result) where the language offers a better option — return
  a value, return multiple values (Go, Python tuples), or return a
  small result object. Readers expect data to flow in through
  arguments and out through the return value; violating that causes a
  double-take.
- If your language supports keyword/named arguments (Python, C#,
  Ruby, Clojure maps), prefer them once you're past two or three
  arguments — they remove the ordering risk that motivates the
  "three argument" guideline in the first place.

## Command/query separation

A function should either **do** something (a command, with a side
effect) or **answer** something (a query), not both. `set(key, value)`
that returns `true`/`false` for success creates an ambiguous call site
(`if (set("username", "bob"))` — set to what? successfully set?).
Split into a query (`attributeExists`) and a command (`setAttribute`)
where practical. This is a convention to lean on, not an absolute —
`stack.pop()` violates it and is still fine in most codebases; know
when the convenience outweighs the ambiguity (and note that violating
CQS here does introduce a real concurrency risk if `pop` isn't atomic).

## Prefer exceptions to error codes

- Returning error codes forces the *caller* to check immediately,
  which nests badly (`if (delete(page) == E_OK) { if (...) { ... } }`)
  even when you flatten it with early-return guards — the nesting was
  really always there, just hidden.
- Exceptions (or a language's idiomatic equivalent — Go's `error`
  return, Rust's `Result`) let you separate the happy path from error
  handling entirely, which is easier to read and to change.
- **Extract try/catch bodies into their own functions.** A function
  containing a `try` should be about error handling and nothing else;
  put the actual logic in a separate function it calls.
- **Error handling is one thing** — so a function that does error
  handling shouldn't also do other work. If a function has a `try`, in
  most cases that `try` should be the first real statement in the
  function, with nothing but the `catch`/`finally` handling after it.
- If you must use error codes (a language without exceptions, or a
  particular API convention), keep the error type/enum in one place
  behind a stable interface so adding new error cases doesn't force
  unrelated recompilation/redeployment across the codebase (the
  "dependency magnet" problem).

## DRY, judged correctly

- Duplication is worth extracting more aggressively as either the
  duplicated block gets longer, or the number of duplicated
  occurrences grows.
- **But**: before merging two similar-looking blocks, ask whether
  they're *essential* duplication (they'll always change together,
  for the same reason) or *accidental* duplication (they look similar
  today but serve different actors/stakeholders and will evolve
  independently). Merging accidental duplicates re-couples things that
  should stay independent, and a future change for one caller will
  silently break the other. When in doubt, check whether the two call
  sites answer to the same "reason to change" (see SRP).
- For duplicated *loop bodies* over the same data structure (walk the
  same tree/list in many places with different per-item logic), factor
  out the traversal once and inject the per-item behavior — a lambda,
  a Strategy/Command object, or a Template Method subclass, depending
  on what's idiomatic in the language.

## Switch statements / if-else chains on type

A switch/if-else chain that branches on an object's "type" is hard to
keep small and, by nature, does more than one thing — and every new
case means editing every such chain across the codebase. Where the
system will keep growing new *behaviors* more often than new *types*,
that's fine, even preferable (see `objects-and-classes.md` for the
trade-off). Where new *types* are the thing that grows, bury the
switch once — typically in a factory at the boundary of the system —
so the rest of the codebase uses polymorphism instead of repeating the
type check.

## Purity, as much as is practical

A function's *external* observable purity — that its result depends
only on its arguments and it doesn't visibly change other functions'
behavior — is what actually matters for testability and concurrency
safety, not whether it has zero internal mutable state. A function can
reassign local variables or use a private mutable helper object
internally and still be pure to every outside observer, as long as
none of that leaks. When you can make a function pure (or pure to its
observers) at low cost, it's easier to test, easier to reason about
under concurrency, and easier to compose — prefer it when it doesn't
fight the language or the problem.
