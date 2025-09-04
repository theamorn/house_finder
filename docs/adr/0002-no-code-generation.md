# ADR 0002: Drop code generation (freezed, json_serializable)

- **Status:** Accepted
- **Date:** 2025-09-04
- **Deciders:** Nan, Bank

## Context

We used `freezed` and `json_serializable` for the model layer. Every model
change meant running `build_runner`, which took 35–50 seconds on the team's
machines and longer in CI. Generated files also produced noisy diffs in review
and occasionally went stale, producing confusing compile errors.

Since we started using AI coding assistants heavily, the original argument for
codegen — "nobody wants to hand-write `fromJson`" — no longer holds. Writing
the boilerplate is now close to free, and reading it is easier than reading a
generated file.

## Decision

Remove `freezed`, `json_serializable` and `build_runner`. Hand-write model
constructors, `fromJson` and `toJson`.

## Consequences

- No generated files in the repo. No `.g.dart`, no `.freezed.dart`.
- A clean build no longer has a codegen step.
- Model changes are a single-file edit.
- We lose compile-time exhaustiveness on unions. We had two, both trivial.
- **Do not reintroduce `build_runner` without revisiting this ADR.**
