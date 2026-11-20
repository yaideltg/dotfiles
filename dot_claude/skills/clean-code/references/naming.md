# Naming

Names are the cheapest, highest-leverage tool for making code readable.
A name should answer *why it exists*, *what it does*, and *how it's
used* without needing a comment next to it.

## Intention-revealing names

If you'd need a comment to explain a name, the name has failed.

```
int d; // elapsed time in days      →   int elapsedDays;
```

Longer isn't automatically better — *clearer* is what matters. A tiny
scope (a loop counter used for two lines) can keep a short name; once
a name crosses function boundaries or represents a domain concept, it
earns a real name.

Build a whole **system of names** for a domain, not just isolated good
names. `getThem()` iterating `theList` for `x[0] == 4` tells the reader
nothing; `getFlaggedCells()` iterating `gameBoard` for
`cell.isFlagged()` explains the whole feature just from the names.

## Avoid disinformation

- Don't call something `accountList` unless it's actually a `List`
  type — use `accountGroup`, `accounts`, etc. otherwise.
- Don't use near-identical names for unrelated things
  (`XYZControllerForEfficientHandlingOfStrings` vs.
  `...StorageOfStrings`) — the similarity itself is misleading.
- Watch out for visually similar characters (`l` vs `1`, `O` vs `0`) in
  fonts that don't distinguish them well.

## Make meaningful distinctions

- Don't rename to satisfy the compiler (`klass` instead of `class`,
  `a1`/`a2` instead of `source`/`destination`).
- Avoid noise words that add no information: `ProductInfo` vs
  `Product`, `NameString` vs `Name`, `CustomerObject` vs `Customer`.
  Every class contains "data" and "info" — saying so adds nothing.
- If you see `X1, X2, X3`, that's the code asking for an array, a
  data structure, or genuinely different names — not a numbering
  scheme.

## Pronounceable and searchable

- If you can't say a name out loud in conversation, it's a tax on
  every discussion of that code (`genymdhms` → `generated`/`modified`).
- Single-letter names and magic numbers are hard to `grep` for. Prefer
  `WORK_DAYS_PER_WEEK` over a bare `5` scattered through the code.
  Short names are fine only in a small, well-known scope (a loop
  index, `e` for a caught exception in a two-line `catch` block).

## Name length is a function of scope

- **Variables**: short scope → short name is fine (`for (int i...)`
  over two lines doesn't need `theCurrentIndexValue`). Instance
  variables and globals need longer, more descriptive names because
  their scope is larger.
- **Functions/methods**: the opposite. A globally-called function can
  and should have a short name (`open`, not
  `openFileAndThrowExceptionIfNotFound`) because it's general and used
  everywhere. A private helper called from exactly one place can
  afford — and often needs — a long, precise name, because it's
  narrow and specific.
- **Classes**: same direction as functions — broadly-scoped classes
  get short names; derived/inner/private classes can be longer and
  more specific.

## Avoid encodings

No Hungarian notation, no `m_` member prefixes, no `I` prefix on
interfaces (`ShapeFactory` + `ShapeFactoryImpl`, not `IShapeFactory` +
`ShapeFactory`). Modern type systems, IDEs, and syntax highlighting
already do this job — encoding it into the name just adds a layer of
decoding for every reader, and it goes stale the moment the type
changes but the name doesn't.

## Parts of speech

- Classes/objects: nouns (`Customer`, `AddressParser`) — singular
  unless it's a collection of many.
- Avoid noise-word class names: `Manager`, `Processor`, `Data`, `Info`
  as a suffix rarely adds meaning.
- Methods: verbs (`postPayment`, `deletePage`, `save`); accessors,
  mutators, predicates follow the host language's convention
  (`get`/`set`/`is` in Java, bare nouns in some others — follow
  whatever's already used in the codebase).

## Pick one word per concept

Don't let `fetch`, `get`, and `retrieve` all mean the same thing
across a codebase — that inconsistency defeats autocomplete and forces
readers to check whether the difference is meaningful. Audit for
consistency within a class, module, or file when you touch it.

## Context

A bare variable like `state` is ambiguous — part of an `Address`? A
finite-state machine? Group related variables into a class or struct
(`Address`) so the name's context is explicit rather than inferred.
Conversely, don't add gratuitous context: don't prefix every class in
an app called "Gas Station Deluxe" with `GSD` — it fights the IDE's
autocomplete and adds nothing.

## Don't be cute

Choose clarity over cleverness or in-jokes: `deleteItems`, not
`HolyHandGrenade`. The name has to survive being read by someone who
doesn't share the joke, possibly years later.
