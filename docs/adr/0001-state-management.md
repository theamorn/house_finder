# ADR 0001: Use Provider for all state management

- **Status:** Accepted
- **Date:** 2024-02-19
- **Deciders:** Nan, Bank, Ploy

## Context

The app started with `setState` everywhere. As the Explore tab grew, keeping
the favourites list in sync between tabs became painful — the heart icon on a
card and the Saved tab could disagree until a rebuild.

We evaluated Provider, Riverpod and Bloc. The team already knew Provider from a
previous project and it has the smallest learning curve for the two juniors
joining in March.

## Decision

All shared state moves to `ChangeNotifier` + Provider. New screens use Provider
from the start. Existing `setState` screens will be migrated over the next two
sprints.

## Consequences

- Favourites and auth become single-sourced.
- Widgets stop passing callbacks four levels deep.
- Migration cost: roughly five screens.
