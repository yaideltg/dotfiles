# SOLID and Simple Design

Use these as diagnostic vocabulary for *why* a design is rigid,
fragile, or hard to extend — not as boxes to tick on every class.

## Simple Design (Kent Beck's four rules, in priority order)

1. **Passes its tests** — correctness comes first, always.
2. **Reveals intent** — clear naming and structure (this is most of
   what the rest of this skill is about).
3. **No duplication** — see DRY in `functions.md`, including the
   essential-vs-accidental judgment call.
4. **Minimizes the number of elements** (classes, methods) — don't
   over-split into so many tiny pieces that navigating the system
   costs more than the clarity it buys.

Rule 4 is a real counterweight to the rest of this skill: it's
possible to over-apply "small functions" and "one class, one
responsibility" until a simple feature is spread across a dozen tiny
files that add no comprehension value. Most real codebases err in the
opposite direction (too large, too tangled) — but when a review
feels like it's manufacturing structure for its own sake, rule 4 is
the check.

## SRP — Single Responsibility Principle

**A module should be responsible to one, and only one, actor** (a
stakeholder or cohesive group of stakeholders who'd request the same
kind of change). This is the most commonly misunderstood SOLID
principle — it is *not* "a class should do only one thing" (that's a
function-level rule, see `functions.md`); it's about which humans'
changes a piece of code answers to. See `objects-and-classes.md` for
the full walkthrough and warning signs.

## OCP — Open-Closed Principle

**Open for extension, closed for modification**: it should be possible
to add new behavior without editing existing, working code. At the
architecture level, this means arranging dependencies so that
higher-level policy (business rules) doesn't depend on, and isn't
disrupted by, changes to lower-level details (UI, database,
presentation format). The direction of the dependency arrows —not just
the number of layers — is what determines which parts are protected
from change in which parts.

## LSP — Liskov Substitution Principle

Any implementation of an interface/base type should be substitutable
for another without breaking the correctness of code that uses the
interface. The canonical violation is `Square` inheriting from
`Rectangle`: if callers can independently set width and height on a
`Rectangle`, a `Square` breaks that contract, forcing callers to
special-case it with `instanceof` checks — which is itself a hidden
OCP violation. Applies beyond class inheritance too: multiple REST
services meant to implement "the same" endpoint, or multiple duck-typed
implementations in a dynamic language, are equally bound by this — if
one implementation quietly diverges from the shared contract (e.g. a
field named differently), every caller has to grow special cases for
it.

## ISP — Interface Segregation Principle

**Don't force a client to depend on methods it doesn't use.** A fat
interface (or a dependency that pulls in far more than a caller
actually needs) creates unnecessary coupling: changes to the parts a
client doesn't use can still force it to be rebuilt, redeployed, or
broken by unrelated failures. Split large interfaces into smaller,
client-specific ones where the language's dependency model makes that
matter (this is a much stronger effect in statically-typed,
compiled languages than in dynamically typed ones, but the design
principle — don't depend on more than you use — still applies
everywhere).

## DIP — Dependency Inversion Principle

**Depend on abstractions, not concretions**, for the volatile,
frequently-changing parts of a system. Source code dependencies should
point toward stable interfaces/abstract types, with concrete,
volatile implementations depending *inward* on those abstractions
(inverted relative to the historical "high-level calls low-level
directly" pattern). In practice:

- Don't name/import/reference a volatile concrete class directly from
  high-level policy code — depend on an interface instead.
- Don't inherit from a volatile concrete class.
- Don't override a concrete function to specialize it — make it
  abstract instead and provide implementations.
- Use an Abstract Factory (or equivalent) to create instances of
  volatile concrete types without the high-level code depending on
  them directly.

This is a rule to apply gradually as the pain of a concrete dependency
shows up, backed by a test suite you trust — not something to apply
maximally everywhere upfront. Stable, unlikely-to-change dependencies
(a language's standard library, well-established platform APIs) are
fine to depend on directly; DIP is about the parts of the system that
are still actively changing.

## How these fit together

SRP tells you *where the seams are* (group code by which actor it
serves). OCP tells you *which direction dependencies should point*
across those seams (toward the more stable/central policy). LSP tells
you whether an abstraction you introduced is actually trustworthy
(can any implementation be swapped in safely). ISP tells you whether
that abstraction is *too big*, forcing unnecessary coupling. DIP tells
you how to wire the dependencies so the seams actually protect what
they're supposed to protect. Treat a design critique that names one of
these as more actionable than "this feels off" — it points at a
specific, fixable structural cause.
