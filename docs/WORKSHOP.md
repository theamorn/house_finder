# Workshop facilitator notes

**Do not hand this file to attendees before the day.** It lists every landmine
and which module uses it.

This is the brownfield repo for *Agentic Engineering for Mobile*. It is a real,
running Flutter app with deliberately realistic problems. Nothing here is
broken for the sake of being broken — every flaw is one you would find in a
three-year-old production app.

## Running it

```bash
fvm flutter pub get
fvm flutter run
```

Login: `demo@housefinder.app` / `password123`

## The landmines, and where each is used

| # | Landmine | Where | Used in |
|---|---|---|---|
| 1 | **1,376-line god file**: Explore tab, detail screen, filter sheet, sort sheet and schedule sheet all in one — 36% of the app's 3,787 lines | `lib/screens/home/home_screen.dart` | M4 context engineering, LAB 1 |
| 2 | Three naming conventions for the same concept: `screens/`, `pages/`, `views/`, plus `features/` | `lib/` | M4 "architecture is now a prompt" |
| 3 | Two state-management styles. Provider for auth + favourites; setState for Explore, News, Viewings | everywhere | M5 ratchet: the agent picks the wrong one unless told |
| 4 | `RegisterScreen` bypasses `AuthProvider` and calls `MockApi` directly | `lib/auth/register_screen.dart` | ratchet exercise |
| 5 | **RenderFlex overflow, 124–281px, on every featured card** | `lib/screens/home/home_screen.dart` `_buildFeaturedCard` | **M8 live demo target** |
| 6 | Flaky test: `MockApi.fetchNews()` throws ~1 call in 4. Measured 6/10 runs fail | `test/news_service_test.dart` | M8 goal loop — agent will try to delete it |
| 7 | Only test in the repo. No golden tests, no widget tests | `test/` | M8 verifier ladder, QA agent |
| 8 | **54 analyzer issues, 0 errors** — 29 `deprecated_member_use` (`withOpacity`, `WillPopScope`), 14 `avoid_print`, 6 `use_build_context_synchronously`, 3 `avoid_dynamic_calls`, 2 other | everywhere | M8 verifier ladder rung 2 |
| 9 | Price formatting duplicated 4 ways: `formatPrice()`, plus three different inline versions | `core/utils/formatters.dart` + `home_screen.dart` | subagent search demo |
| 10 | Half-migrated l10n. Only the login screen uses `AppLocalizations`, and only for 2 of its 6 strings | `lib/l10n/`, `lib/auth/login_screen.dart` | ratchet: hardcoded strings |
| 11 | Fake secrets that must never be edited | `.env`, `android/key.properties`, `android/app/google-services.json` | M5 deny-list vs rule |
| 12 | **Stale README contradicts ADR 0002** — tells you to run `build_runner`, which was removed | `README.md` vs `docs/adr/0002` | M7 memory rot: a wrong doc is worse than no doc |
| 13 | Aspirational ADR the code violates — ADR 0001 says "Provider everywhere", half the app ignores it | `docs/adr/0001` | M4 anti-patterns |
| 14 | Settings toggles that persist nowhere | `lib/features/profile/profile_screen.dart` | filler / QA agent target |
| 15 | CI runs `analyze --no-fatal-infos --no-fatal-warnings` — which is *why* 54 warnings survived three years | `.github/workflows/ci.yml` | M9: a gate that never fails is not a gate |

## Two things to decide before the day

1. **`docs/WORKSHOP.md` is committed to `main`.** It lists every answer. Move
   it to a `facilitator` branch, or delete it from the attendee copy.
2. **`README.md` tells you to run `build_runner`, which will fail.** That is
   landmine 12 and it is used in M7 — but it will also be the first thing a
   confused attendee hits. Put the correct commands in the pre-course email:
   `fvm flutter pub get && fvm flutter run`. Do not fix the README.

## Baseline numbers (verify before the workshop)

Re-measure on your machine and update — attendees will compare against these.

| Rung | Command | Observed |
|---|---|---|
| 1 | `dart format --output=none --set-exit-if-changed .` | 0.05s — 9 of 23 files unformatted |
| 2 | `fvm flutter analyze` | ~1.6s — **0 errors, 54 issues** |
| 3 | `fvm flutter test` | ~2s — **6 of 10 runs fail** (measured) |
| 4 | golden tests | none exist yet |
| 6 | `fvm flutter build apk --debug` | **163s** cold (Gradle), measured |

**The ratio is the whole lesson.** Rung 2 costs 1.6 seconds and catches every
one of the 54 issues. Rung 6 costs 163 seconds — **102× more** — and catches
almost nothing rung 2 missed. An agent that reaches for a build to check a typo
has burned a hundred analyzer runs.

Put that on a slide as two bars. It argues better than any sentence you can say.

### The overflow bug, measured

Every featured card overflows. Verified against all five featured listings:

| Listing | Overflow |
|---|---|
| Modern 3-Bed House with Garden | 281 px |
| Penthouse Apartment, Chit Lom | 267 px |
| Riverside Condo, High Floor | 238 px |
| Loft Apartment, Ari | 124 px |
| Pool Villa, Bang Na | 124 px |

Cause: `_buildFeaturedCard` puts `Text(property.title)` in a `Row` with no
`Expanded`/`Flexible`, inside a fixed 260px card. Fix is one word. It throws a
real `RenderFlex` exception, so the Dart MCP server surfaces it as a runtime
error with the widget tree — which is exactly what the live demo needs.

## Lab targets

- **LAB 1** — write `AGENTS.md` + `.github/copilot-instructions.md`. The repo
  gives them plenty to say: which state management, which directory, don't
  touch secrets, don't reintroduce build_runner.
- **LAB 2** — `docs/FEATURE_REQUEST.md` is the input. It is vague on purpose;
  roughly six real decisions are hiding in it.
- **M8 ratchet exercise** — ask for a new screen. The agent will pick the wrong
  state management, because nothing tells it which to use. That is the failure
  everyone writes a rule against.

## Deliberately NOT here

- No `freezed`, `json_serializable` or `build_runner`. See ADR 0002 — that
  decision is itself a teaching beat about loop economics.
- No `AGENTS.md`, `CLAUDE.md` or `.github/copilot-instructions.md`. Attendees
  write those. Shipping them would remove LAB 1.
