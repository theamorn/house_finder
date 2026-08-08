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
| 1 | 1,400-line god file: Explore tab, detail screen, filter sheet, sort sheet and schedule sheet all in one | `lib/screens/home/home_screen.dart` | M4 context engineering, LAB 1 |
| 2 | Three naming conventions for the same concept: `screens/`, `pages/`, `views/`, plus `features/` | `lib/` | M4 "architecture is now a prompt" |
| 3 | Two state-management styles. Provider for auth + favourites; setState for Explore, News, Viewings | everywhere | M5 ratchet: the agent picks the wrong one unless told |
| 4 | `RegisterScreen` bypasses `AuthProvider` and calls `MockApi` directly | `lib/auth/register_screen.dart` | ratchet exercise |
| 5 | **RenderFlex overflow, 124–281px, on every featured card** | `lib/screens/home/home_screen.dart` `_buildFeaturedCard` | **M8 live demo target** |
| 6 | Flaky test: `MockApi.fetchNews()` throws ~1 call in 4. Measured 6/10 runs fail | `test/news_service_test.dart` | M8 goal loop — agent will try to delete it |
| 7 | Only test in the repo. No golden tests, no widget tests | `test/` | M8 verifier ladder, QA agent |
| 8 | 54 analyzer warnings nobody fixes: `withOpacity`, `WillPopScope`, `print`, `use_build_context_synchronously` | everywhere | M8 verifier ladder rung 2 |
| 9 | Price formatting duplicated 4 ways: `formatPrice()`, plus three different inline versions | `core/utils/formatters.dart` + `home_screen.dart` | subagent search demo |
| 10 | Half-migrated l10n. Only the login screen uses `AppLocalizations`, and only for 2 of its 6 strings | `lib/l10n/`, `lib/auth/login_screen.dart` | ratchet: hardcoded strings |
| 11 | Fake secrets that must never be edited | `.env`, `android/key.properties`, `android/app/google-services.json` | M5 deny-list vs rule |
| 12 | **Stale README contradicts ADR 0002** — tells you to run `build_runner`, which was removed | `README.md` vs `docs/adr/0002` | M7 memory rot: a wrong doc is worse than no doc |
| 13 | Aspirational ADR the code violates — ADR 0001 says "Provider everywhere", half the app ignores it | `docs/adr/0001` | M4 anti-patterns |
| 14 | Settings toggles that persist nowhere | `lib/features/profile/profile_screen.dart` | filler / QA agent target |

## Baseline numbers (verify before the workshop)

Re-measure on your machine and update — attendees will compare against these.

| Rung | Command | Observed |
|---|---|---|
| 1 | `dart format --output=none .` | < 1s |
| 2 | `fvm flutter analyze` | ~1s, **0 errors / 54 issues** |
| 3 | `fvm flutter test` | ~2s, **fails ~60% of runs** |
| 4 | golden tests | none exist yet |
| 6 | `fvm flutter build apk --debug` | measure on the day |

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
