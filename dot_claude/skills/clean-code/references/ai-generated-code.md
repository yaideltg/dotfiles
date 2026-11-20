# Writing Code from Prompts (Clean Code, Ch. 17)

This is the one chapter of the book aimed squarely at how AI-assisted
coding should work, and it's directly relevant to how you (Claude)
should operate — not just something to apply to code a human wrote.

## The core argument

Natural-language prompts are ambiguous. An LLM generating code from an
ambiguous prompt will confidently produce *something* that satisfies a
plausible reading of it — which is not the same as producing what was
actually meant. The book's illustration: a detailed but informal
prompt asking for a program that walks sentences containing a
substring produces code with real, subtle bugs (extra whitespace,
inconsistent casing) that trace directly back to undefined terms in
the prompt ("word," "sentence," "the found word"). Tightening the
prompt with formal definitions still didn't fully save it — the model
even ignored some of the explicit definitions it was given.

The proposed fix is **overloading**: state the intent in more than one
way, so an error in one statement is likely to be caught by the other.
Concretely, the book pairs a semi-formal spec (definitions, command
line contract, constraints) with **Given/When/Then test scenarios**,
because a test scenario and a prose description are different enough
in form that they rarely fail in the exact same way at once — the same
logic behind double-entry bookkeeping.

## What this means in practice, for you

- **Don't silently resolve ambiguity by picking whichever
  interpretation is easiest to implement.** If a request leaves a term
  or an edge case undefined (what counts as "active," what happens on
  empty input, whether comparison is case-sensitive), state the
  assumption you're making in one line, rather than letting it live
  only inside the implementation where it's invisible.
- **Treat tests as the second, formal statement of the requirement**,
  not an optional extra. When you implement new behavior, write (or
  update) a test that encodes the same intent independently of the
  implementation. If the implementation and the test were both derived
  from the same ambiguous understanding, at least a *future* change to
  either one is now checked against something concrete.
- **Don't regenerate/rewrite large working chunks of code to satisfy a
  small new requirement.** The chapter's example shows exactly this
  failure mode: each new prompt made the model produce a fresh
  implementation with a different bug profile, because nothing forced
  continuity with the previous, working version. Prefer the smallest
  targeted diff that satisfies the new requirement — this is the same
  instinct as "small functions" and the Boy Scout Rule, applied at the
  scale of a whole change.
- **When a request is genuinely underspecified in a way that matters**
  (behavior on invalid input, concurrency expectations, what "correct"
  means for a domain-specific term), it's worth asking a short,
  concrete clarifying question rather than guessing — especially when
  the two plausible readings would produce different observable
  behavior, not just different code shape.
- **Verify against something other than "it looks plausible."** Run
  the tests, run the code, or at minimum trace through the stated
  scenarios by hand before presenting a change as done — an LLM's own
  confidence that code is correct is not itself evidence that it is.

## Why this belongs in a "clean code" skill specifically

Everything else in this skill is about making code legible to a human
reader. This chapter is about making the *requirement* legible enough,
in the first place, that the resulting code has a chance of being
correct — which is a precondition for all the rest of it mattering.
