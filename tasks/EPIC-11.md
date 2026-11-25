# tripmate-mobile -- EPIC-11 Tasks: Platform Foundation

**Document type:** Task file\
**Epic:** EPIC-11, first part, Phase 1\
**Repository:** `tripmate-mobile`\
**Machine:** Mac 2\
**Spec:** [EPIC-11 spec](https://github.com/huynguyennang-agilityio/tripmate-docs/blob/main/docs/specs/epic-11/spec.md)\
**Status:** Proposed\
**Version:** 1.0

The tasks of EPIC-11 in this repository, in the order they start. Each task holds everything its Trello card will say ([development-flow.md](https://github.com/huynguyennang-agilityio/tripmate-docs/blob/main/docs/development-flow.md), section 1). The behaviour, the design, the order of the cards across repositories, and the checkpoints are in the spec, section 6.

Test case levels are the letters of [test-strategy.md](https://github.com/huynguyennang-agilityio/tripmate-docs/blob/main/docs/test-strategy.md), section 2. A case of level M has no automated test; it is shown once by hand and listed under Manual checks.

| Task | Title | Size | Risk | Depends on | Wave |
|------|-------|------|------|------------|------|
| [MF1](#mf1) | Mobile skeleton and CI | S | High | -- | 1 |
| [MF2](#mf2) | Mobile API client and mock mode | M | High | MF1, CT2 | 3 |

## MF1

**MF1 Mobile skeleton and CI**

**Facts**

| Fact | Value |
|------|-------|
| Epic | EPIC-11 |
| Repository | `tripmate-mobile` |
| Machine | Mac 2, wave 1 |
| Size | S |
| Risk | High: it adds CI, `CLAUDE.md`, and the agent roles |
| Depends on | -- |
| Requirements | -- |
| Spec sections | 2.11, 4.3 |

**Scope**

- A Flutter project following the conventions of 2.11: Flutter 3.38.5 pinned, `flutter_bloc`, `go_router`, a folder per feature, `flutter_lints` with warnings as errors.
- The `dev` and `prod` flavors on Android and iOS with their application IDs and names; the `API_MODE` setting.
- `flutter analyze --fatal-infos --fatal-warnings`, `flutter test`, and the Android build required on `main`.
- `CLAUDE.md` with the conventions, `.gitattributes`, and the four agent roles (4.3).

**Leaves out**

- The generated client, ARB files, mock mode, and the flow checks: MF2.
- An iOS build in CI.

**Done when**

Flutter project with the two flavors on Android and iOS, the mock mode setting, and the project conventions of 2.11; `flutter analyze`, `flutter test`, and the Android build required on `main`; `CLAUDE.md`, `.gitattributes`, and the four agent roles (4.3)

**Test cases**

| Case | Kind | Given | Expected | Level |
|------|------|-------|----------|-------|
| MF1-1 | Main | The project with no problem | Analysis, tests, and the Android build pass, and each is required on `main` | M |
| MF1-2 | Main | The `dev` and `prod` flavors on one phone | Both install side by side | M |
| MF1-3 | Error | An analysis warning or a failing test | The matching check fails | M |
| MF1-4 | Main | The app started with the `dev` flavor; then with `prod` | Its first screen shows "TripMate Dev"; then "TripMate" | U |

**Manual checks**

- [ ] MF1-1: The project with no problem → Analysis, tests, and the Android build pass, and each is required on `main`
- [ ] MF1-2: The `dev` and `prod` flavors on one phone → Both install side by side
- [ ] MF1-3: An analysis warning or a failing test → The matching check fails

## MF2

**MF2 Mobile API client and mock mode**

**Facts**

| Fact | Value |
|------|-------|
| Epic | EPIC-11 |
| Repository | `tripmate-mobile` |
| Machine | Mac 2, wave 3 |
| Size | M |
| Risk | High: it adds the generated client and the flow checks |
| Depends on | MF1, CT2 |
| Requirements | Cross-client API contract tests |
| Spec sections | 2.11, 2.9, 2.12 |

**Scope**

- ARB files generated from the pinned contracts version.
- The `dart-dio` client generated with OpenAPI Generator; a Dio interceptor answering from the contract's examples when built with `--dart-define=API_MODE=mock` and in widget tests; an operation with no example fails with its name instead of returning made-up data.
- `X-Device-Id` on every request, kept across restarts; `Idempotency-Key` on creates, the same for retries of one action.
- One test screen reads `GET /v1/health` in both modes.
- The checks that the generated client and ARB files match the pinned version, and the flow checks of 2.12, required on `main`.

**Leaves out**

- Feature screens: EPIC-01 and later.

**Done when**

ARB files generated from the pinned contracts version; the generated `dart-dio` client, the mock interceptor answering from the contract's examples, the headers of 2.11; one test screen reads `GET /v1/health` in both modes; the remaining checks of 2.9 and the flow checks of 2.12 required on `main`

**Test cases**

| Case | Kind | Given | Expected | Level |
|------|------|-------|----------|-------|
| MF2-1 | Main | Built with `API_MODE=mock` | The test screen shows the example of `GET /v1/health` from the pinned contract | S |
| MF2-2 | Main | The `dev` flavor against the local stack | The test screen shows the real answer | M |
| MF2-3 | Main | Any request | It carries `X-Device-Id`, the same value after the app restarts | U |
| MF2-4 | Main | A create request that is retried | Both attempts carry the same `Idempotency-Key` | U |
| MF2-5 | Edge | An operation whose contract has no example, in mock mode | The interceptor fails with the operation's name; it returns no made-up data | U |
| MF2-6 | Error | The generated client does not match the pinned contracts version | The check fails | C |
| MF2-7 | Main | A widget test of one message key | The key shows its text in Vietnamese and in English | S |
| MF2-8 | Error | The generated ARB files do not match the pinned contracts version | The check fails | C |

**Manual checks**

- [ ] MF2-2: The `dev` flavor against the local stack → The test screen shows the real answer
- [ ] Checkpoint: Together with CT2 and the other client: a stub route becomes a draft tag, and the test screen on Web and on Mobile shows its example in mock mode. EPIC-01 can start with B0.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-11-25 | First version: the 2 tasks of EPIC-11 in this repository, moved from the EPIC-11 spec, sections 6 and 7, with scope, what each leaves out, the reason for its risk level, and its manual checks. The skeleton tasks write four agent roles, as development-flow.md now says. |
