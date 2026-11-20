# Objects, Data Structures, and Classes

## Objects vs. data structures: pick one deliberately

- **Objects** hide their data behind an abstraction and expose
  behavior (methods). Adding a new *type* (a new class implementing an
  interface) is cheap and doesn't touch existing code; adding a new
  *operation* to the interface requires touching every implementing
  class.
- **Data structures** expose their data (public fields or plain
  getters/setters with no real behavior) and have no meaningful
  functions of their own; a separate module/class operates on them.
  Adding a new *operation* (function) is cheap; adding a new *data
  variant* requires touching every function that switches on the
  shape of the data.

These are near-opposites, and that's fine — the right choice depends
on which axis of your system is more likely to grow:

- Expect new **data types** to be added over time (e.g. an
  application's plugin shapes, new payment methods)? → favor objects
  with polymorphism.
- Expect new **operations/behaviors** to be added over time on a
  relatively fixed set of data shapes (e.g. an enterprise database
  schema, a fixed set of report row types)? → favor data structures
  with functions/switches operating on them.

Don't build **hybrids** — a class with both real behavior *and* public
fields/naive getters-and-setters that expose its internals. Hybrids
combine the worst of both: hard to add new operations *and* hard to
add new data types.

## Don't reflexively add getters/setters

A `Point` with public `x`/`y` fields (or naive `getX()`/`setX()`)
exposes its implementation — a caller can tell it's rectangular
coordinates and manipulate the two independently. An interface with
`getR()`/`getTheta()`/`setPolar(r, theta)` hides the representation
entirely *and* encodes a policy (the two polar values must be set
together atomically). Before adding a getter/setter, ask what
abstraction you actually want to expose, not just "how do I read/write
this field."

## Data Transfer Objects (DTOs)

Plain structures with public data and no behavior are legitimate and
useful — for parsing wire formats, database rows, config, etc. Don't
force behavior onto them just to feel "more OO"; a DTO is doing its
job by being a plain, honest data structure.

## Law of Demeter

A method `f` of class `C` should only call methods on: `C` itself, an
object `f` created, an object passed as an argument to `f`, or an
object held in a field of `C`. It should **not** call methods on
objects returned by any of those calls.

```
// train wreck — violates the law when these are real objects
ctxt.getOptions().getScratchDir().getAbsolutePath();
```

This only applies when the intermediate objects (`ctxt`, `Options`,
`ScratchDir`) are genuine objects hiding behavior — if they're plain
data structures, navigating their public fields is not a violation
(`ctxt.options.scratchDir.absolutePath` is fine for a DTO chain).

The fix is usually **"tell, don't ask"**: instead of reaching through
an object to gather what you need, tell the outer object to do the
whole thing:

```
BufferedOutputStream bos = ctxt.createScratchFileStream(classFileName);
```

## Class size and the Single Responsibility Principle

A class should be small, cohesive, and responsible to **one actor**
(one stakeholder or group of stakeholders who would ask for a change).
"One reason to change" is the classic phrasing — cohesion is the force
that keeps a class's methods bound to that single actor.

Warning signs a class violates SRP:
- Its methods serve visibly different stakeholders (e.g. a payroll
  `calculatePay()` for accounting, `reportHours()` for HR, `save()`
  for the DBA team, all on one `Employee` class).
- A change requested by one stakeholder risks silently breaking
  behavior another stakeholder depends on, because they share a
  "convenient" internal helper that happens to serve both.
- Policy details (a business rule like "late = returned after due
  date") are buried inline inside a larger method instead of named and
  isolated — that inline conditional is itself a hidden reason to
  change, even if the class's public interface looks fine on a
  diagram.

Fixes, in rough order of ceremony: extract the responsibility into its
own method with a clear name; extract it into its own class if it has
its own data/policy of any complexity; use a Facade to keep a single
convenient entry point if callers shouldn't have to know about the
split. Don't manufacture new classes speculatively — wait for an
actual second reason to change to show up, then split at that seam.

Small, single-purpose classes (even ones with a single public method)
are normal and healthy — resist the instinct to avoid creating a new
class/file "because it's just one method." The cost of a new file is
low; the cost of an overloaded class compounds over the project's
life.

## Switch statements, revisited at the class level

See `functions.md` for the general rule. At the class-design level,
the deciding question is the same: will this system need more new
*shapes of data/type* (favor an OO/polymorphic design, one small class
per type) or more new *operations* on a relatively fixed set of types
(favor a data-structure + functions design, accepting the switch
statement)? Don't force one paradigm where the other fits the
project's actual pattern of change — and don't sacrifice a clean OO
design system-wide just because one hot inner loop needs the last bit
of switch-statement performance; isolate that trade-off narrowly.
