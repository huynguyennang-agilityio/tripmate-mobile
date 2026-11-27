# tripmate-mobile

The TripMate Mobile client: one Flutter app for Android and iOS. This
file holds only what is about this repository's code: setup, commands,
coding conventions, and how a card runs here with its agent roles.
Everything about the product lives in
`../tripmate-docs/` and is never copied here.

## Read first

The repositories are cloned side by side in one folder
(`../tripmate-docs/docs/architecture.md`, section 11).

- Shared rules for every session, on every machine:
  `../tripmate-docs/CLAUDE.md`, section "Working on several machines".
  They cover language (talk with the product owner in Vietnamese; write
  every document, commit, pull request, and card in English), secrets,
  and how status is shared.
- Terms: `../tripmate-docs/GLOSSARY.md`.
- Requirements: `../tripmate-docs/prd.md`.
- Architecture: `../tripmate-docs/docs/architecture.md`.
- API conventions and how the contract moves between repositories:
  `../tripmate-docs/docs/api-design.md`.
- From card to merge (task files, risk levels, the steps, the four
  agents, the test check, the diff review, notes, naming, Definition
  of Done): `../tripmate-docs/docs/development-flow.md`, sections 1
  to 3.
- The tasks of this repository: `tasks/<epic>.md`, for example
  [`tasks/EPIC-11.md`](tasks/EPIC-11.md). Each task holds what its
  Trello card says: facts, scope, Done when, test cases, and manual
  checks.
- How the app is tested: `../tripmate-docs/docs/test-strategy.md`.
- The spec of the epic being built, under
  `../tripmate-docs/docs/specs/<epic>/spec.md`. The Mobile foundations
  are in `../tripmate-docs/docs/specs/epic-11/spec.md`, section 2.11.

Pull `tripmate-docs` before you start a card. When a document has a gap
or a contradiction, stop and ask the product owner.

## Setup on a new machine

1. Install Flutter **3.38.5** (Dart 3.10.4) exactly. `pubspec.yaml`
   pins both exactly (`environment: sdk: 3.10.4`, `flutter: 3.38.5`),
   so `flutter pub get` fails with "version solving failed" on any
   other Dart SDK or Flutter version, older or newer. Every `flutter`
   command (analyze, test, run, build) runs that resolution first, so
   a machine on another version cannot work silently. With
   [fvm](https://fvm.app): `fvm install 3.38.5 && fvm use 3.38.5`.
2. Android: Android Studio with the Android SDK and its bundled JDK
   (17 or 21). Run `flutter doctor --android-licenses`.
3. Java 17 or later for `tool/contracts.dart` and its tests (OpenAPI
   Generator). Set `JAVA_HOME`, or put `java` on `PATH`. On macOS the JDK
   of Android Studio works:
   `export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"`.
   `git` and access to pub.dev are needed too.
4. iOS (macOS only): Xcode with an iOS simulator and CocoaPods
   (`shared_preferences` has native iOS code; see "iOS flavors").
5. Clone the repositories side by side (above), then:

   ```sh
   cd tripmate-mobile
   flutter pub get
   flutter doctor
   ```

6. To run on a physical iPhone, create `ios/Flutter/Signing.xcconfig`
   with one line, `DEVELOPMENT_TEAM = <your team ID>`. The file is
   ignored by Git, so no team ID is committed. The simulator needs no
   signing.

No secret, `.env`, keystore, or token is ever committed: the repository
is public.

## Commands

Every run and build names a flavor; there is no build without one.

| Task | Command |
|------|---------|
| Run `dev` on the Android emulator | `flutter run --flavor dev -d emulator-5554` |
| Run `prod` on Android | `flutter run --flavor prod -d <android device>` |
| Run `dev` on the iOS simulator | `flutter run --flavor dev -d <simulator name or ID>` |
| Run `prod` on iOS | `flutter run --flavor prod -d <ios device>` |
| Run in mock mode | add `--dart-define=API_MODE=mock`, e.g. `flutter run --flavor dev --dart-define=API_MODE=mock` |
| List devices | `flutter devices` |
| Analyze (as CI) | `flutter analyze --fatal-infos --fatal-warnings` |
| Format | `dart format lib test` (a Claude Code hook also formats each `.dart` file Claude writes: `.claude/settings.json`, `.claude/hooks/format-dart.sh`) |
| Test (as CI) | `flutter test` (the contract-check tests need Java) |
| Generate the client, ARB files, and localizations | `dart run tool/contracts.dart generate` |
| Check them against the pinned contract (as CI) | `dart run tool/contracts.dart check` |
| Android builds (as CI) | `flutter build apk --debug --flavor dev` and `flutter build apk --debug --flavor prod` |
| iOS simulator builds | `flutter build ios --debug --simulator --flavor dev` and `--flavor prod` |

Before a pull request, run analyze, test, the contracts check, and both Android builds, and
get a clean test check (see "From card to merge").

### Flavors

| Flavor | Application / bundle ID | Name | Runs against |
|--------|-------------------------|------|--------------|
| `dev` | `com.tripmate.app.dev` | TripMate Dev | The local stack: `10.0.2.2:8000` from the Android emulator, `localhost:8000` from the iOS simulator |
| `prod` | `com.tripmate.app` | TripMate | Production |

Both apps install side by side on one phone.

- Dart: `lib/main.dart` reads Flutter's `appFlavor` and passes an
  `AppFlavor` (`lib/app/flavor.dart`) to `TripMateApp`. Widget tests
  pass the flavor explicitly.
- Android: product flavors in `android/app/build.gradle.kts`; the name
  comes from the `app_name` string resource of each flavor.
- iOS: six build configurations (`Debug-dev`, `Release-dev`,
  `Profile-dev`, and the same for `prod`) and two shared schemes, `dev`
  and `prod`. Each configuration's `ios/Flutter/<Config>.xcconfig`
  includes Flutter's `Debug.xcconfig` or `Release.xcconfig` and the
  flavor's `dev.xcconfig` or `prod.xcconfig`, which set
  `PRODUCT_BUNDLE_IDENTIFIER` and `APP_DISPLAY_NAME`. Change the bundle
  ID or the name only in those two files.

### iOS flavors and CocoaPods

`ios/Podfile` exists since `shared_preferences` (native iOS code). Flutter
generates a `Podfile` that knows only `Debug`, `Profile`, and `Release`,
so every configuration is mapped in it:

```ruby
project 'Runner', {
  'Debug-dev' => :debug, 'Debug-prod' => :debug,
  'Profile-dev' => :release, 'Profile-prod' => :release,
  'Release-dev' => :release, 'Release-prod' => :release,
}
```

and each `ios/Flutter/<Config>.xcconfig` starts with the matching
`#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.<config>.xcconfig"`
line (`<config>` is lowercase, e.g. `debug-dev`). Flutter itself adds the
`debug` and `release` lines to its own `Debug.xcconfig` and
`Release.xcconfig` on every run; keep them committed so the tree stays
clean. When a new
plugin changes the `Podfile`, check that the mapping is still there.

### Mock mode

`--dart-define=API_MODE=mock` builds the app in mock mode; any other
value, or none, is the real API. `ApiMode.current`
(`lib/app/api_mode.dart`) holds the mode. In mock mode `createDio`
(`lib/core/api/api_client.dart`) adds `MockApiInterceptor`
(`lib/core/api/mock_api.dart`) last: it answers from the examples of
`contracts/openapi.json` (a Flutter asset) and rejects an operation with
no example with a `MissingExampleError` naming its `operationId`; it
never makes data up. Widget tests turn it on with
`TripMateApp(apiMode: ApiMode.mock)` after
`SharedPreferences.setMockInitialValues({})`.

Every request carries `X-Device-Id` (`lib/core/api/device_id.dart`, kept in
`shared_preferences`), and every `POST` an `Idempotency-Key`
(`lib/core/api/idempotency.dart`); a retry sends the same
`RequestOptions` again (`dio.fetch(error.requestOptions)`), so it keeps
the key. A retry that calls the generated method again (a "Try again"
tap, a Cubit retrying after a timeout) builds new options, so it would get
a new key. The interceptor keeps a key that is already set, so a create
that can be retried this way makes one UUID per user action and passes it
as `Options(headers: {IdempotencyKeyInterceptor.header: key})`. The first
card with a create screen adds a helper for it.

The base URL: `dev` is `http://10.0.2.2:8000` on Android and
`http://localhost:8000` elsewhere; `prod` has no default yet (the
production address is not decided) and needs
`--dart-define=API_BASE_URL=<address>`, which also overrides `dev`. In
the `prod` flavor the address must start with `https://`. `main()` calls
`checkApiConfig`, so a real-mode `prod` build without it (or with a
non-https one) stops at startup with a clear message instead of at the
first request.

The test screen `/health` (`lib/features/health/`) shows the `status` and
`version` of `GET /v1/health` in both modes.

### API client and translations (generated)

`CONTRACTS_VERSION` holds the pinned `tripmate-contracts` tag. Everything
that comes from it is generated by `dart run tool/contracts.dart generate`
and never edited by hand:

| Generated | From |
|-----------|------|
| `contracts/` (`openapi.json`, `translations/`) | A byte copy of the tag |
| `packages/tripmate_api/` | The `dart-dio` client (OpenAPI Generator 7.17.0, jar checked by SHA-256, cached outside the repository; `json_serializable`, with its `build_runner` output committed) |
| `lib/l10n/app_<lang>.arb`, `lib/l10n/app_localizations*.dart`, `l10n.yaml` | `translations/<lang>/*.json`; key `auth.not_signed_in` becomes `authNotSignedIn`; `flutter gen-l10n` |

`CONTRACTS_SHA` holds the commit the tag must resolve to; the tool
fetches the tag and fails when it points elsewhere. The build tools of the
generated client are pinned by exact versions in the tool and by the
committed `tool/generator.pubspec.lock` (used with `--enforce-lockfile`);
`generate --update-lock` rewrites that lock when the generator or the tool's
pinned versions change.

To move to a new tag: change `CONTRACTS_VERSION` and `CONTRACTS_SHA`
(`git rev-parse <tag>^{commit}` in `tripmate-contracts`), run `generate`, extract
the tag's files into `test/fixtures/<tag>/` (the tests read them), commit
all of it. `check` regenerates into a temporary folder and prints each
file that differs, is missing, or is extra. Use `--source <dir>` for a
local copy of `tripmate-contracts` and `--root <dir>` for another
repository. Use `AppLocalizations` for every user-facing text; keys with
placeholders need ARB metadata the tool does not write yet.

### CI

`.github/workflows/ci.yml` runs on every pull request to `main` and on
every push to `main`, with Flutter 3.38.5. Its four jobs are the checks
that `main` requires, but the branch protection of `main` lists only
`Analyze`, `Test`, and `Android build` until the product owner adds the
rest right after the MF2 pull request is merged: `Contracts`,
`flow / failing-first`, `flow / test-lock`, and `gate / risk-gate`
(`gate / risk-gate` only once `risk-gate.yml` is on `main`, because a
`pull_request_target` workflow runs from the base; never the skipped
`flow / risk-gate`). Until then MF2 is not done. Each job first runs
`flutter pub get --enforce-lockfile`, which fails when `pubspec.lock`
is missing or does not satisfy `pubspec.yaml`, so CI tests exactly the
committed dependency set; commit `pubspec.lock` with every
`pubspec.yaml` change.

| Job | Runs |
|-----|------|
| `Analyze` | `flutter analyze --fatal-infos --fatal-warnings` |
| `Test` | `flutter test` (with Java 17) |
| `Contracts` | `dart run tool/contracts.dart check` (with Java 17) |
| `Android build` | `flutter build apk --debug --flavor dev` and `--flavor prod` |

**Flow checks** (EPIC-11 spec, section 2.12): `.github/workflows/flow.yml`
(`flow / failing-first`, `flow / test-lock`, and `flow / mutation`, which
is skipped here) and `.github/workflows/risk-gate.yml` (`gate / risk-gate`,
on `pull_request_target`, so a pull request cannot change it) call the
reusable workflows of `tripmate-backend`, pinned to the same commit as
`tripmate-contracts`. `flow / failing-first`, `flow / test-lock`, and
`gate / risk-gate` are to be required on `main` too (see above). The risk levels of paths
are in `.github/risk-paths.toml`; a path no rule names is High. Failing
first runs `flutter test <file>` for each test file a test commit adds
(`test/**/*_test.dart`); "No tests were found." in the output is an error of
the run.

The Flutter version is pinned in three places: `pubspec.yaml`
(`environment: sdk:` and `flutter:`, both exact), `ci.yml`
(`FLUTTER_VERSION`), and `flow.yml` (`setup-command`, `--branch`).
Change all four values together, in one pull request.

## Coding conventions

From the EPIC-11 spec, section 2.11. Every Mobile card follows them.

| Topic | Rule |
|-------|------|
| Flutter version | 3.38.5 (Dart 3.10.4), the same in CI and on every machine |
| State | `flutter_bloc`: a Cubit for a simple screen, a Bloc for a flow with many events; tested with `bloc_test` from a state and an event |
| Routing | `go_router` (`lib/app/router.dart`); it also opens the `/join/*` Universal Links and App Links |
| Lint | `flutter_lints` plus the rules in `analysis_options.yaml`; an info is an error in CI |
| API client | Generated from the pinned `tripmate-contracts` version with OpenAPI Generator, `dart-dio` (`packages/tripmate_api/`). Never edit generated code by hand. |
| Translations | ARB files generated from `tripmate-contracts` into `lib/l10n/`. No user-facing text hard-coded in a widget: use `AppLocalizations`. |

### Folder layout

By feature, so cards that run at the same time do not change the same
files. `test/` mirrors `lib/`.

```text
lib/
├── main.dart              Entry point: reads the native flavor
├── app/                   App-wide setup
│   ├── app.dart           TripMateApp, the root widget
│   ├── flavor.dart        AppFlavor: dev, prod
│   ├── api_mode.dart      ApiMode: real, mock (API_MODE)
│   └── router.dart        go_router routes
├── core/api/              Device id, idempotency key, mock interceptor, createDio
├── l10n/                  Generated ARB files and AppLocalizations
└── features/
    └── <feature>/
        ├── data/          Repositories and data sources, over the generated client
        ├── logic/         Cubits and Blocs
        └── ui/            Screens and widgets
test/
├── app/
└── features/<feature>/{data,logic,ui}/
```

Create a folder only when it gets its first file. A feature reaches
another feature only through `lib/core/` or the router, never by
importing its `data/` or `logic/`.

### Tests

- A test of a task's case has the case ID at the start of its name,
  and the requirement ID when the task has one, e.g. `MF1-4 dev
  flavor: first screen shows "TripMate Dev"`. The case and its expected
  result come from the task in `tasks/<epic>.md`.
- A widget test passes the flavor to `TripMateApp` explicitly; no
  native flavor exists in `flutter test`.

## From card to merge

The flow is `../tripmate-docs/docs/development-flow.md`, sections 2.2
to 2.6; this section says how it runs here.

- **Tasks.** `tasks/<epic>.md` holds the tasks of this repository, for
  example [`tasks/EPIC-11.md`](tasks/EPIC-11.md). It is changed only by
  planning pull requests from Mac 1, approved by the product owner. No
  card changes it; when a task is wrong or leaves something undecided,
  stop and ask.
- **One lead session** takes a card and starts the four agents of
  `.claude/agents/`, each in a new session with no memory of the
  others. Only files pass between them: the test files, the code, the
  reports, and the comments on the pull request.
- Each agent's model is set in its role file: `code-agent` runs on
  Sonnet; `test-agent`, `test-check-agent`, and `diff-review-agent` run
  on Opus (development-flow.md, section 2.3). Do not override it when
  starting an agent.

| Step | Agent (`.claude/agents/`) | Produces |
|------|---------------------------|----------|
| 5. Write the tests | `test-agent` | One test per automated case of the task, shown failing; a test commit with the trailer `Agent: test`; the case-to-test table |
| 6. Write the code | `code-agent` | Code until every test passes; the results of analyze, test, and both Android builds; a note of each decision |
| 7. Check the tests | `test-check-agent`, on this machine | The test-check report: Cases, Lock, Code against tests, Matrix, Results. A test problem goes to a new test agent session, a code problem to the code agent. The pull request opens only when it is clean. |
| 8. Open the pull request | `code-agent` | The pull request with the description below; CI runs |
| 9. Review, round 1 | `diff-review-agent` | Findings at their file and line on the pull request, and a summary comment with the impact and the risk level |
| 10. Fix | `code-agent` | A fix or a reply with the reason for each finding; the fixes pushed |
| 11. Review, round 2 | A new `diff-review-agent`, on the diff since round 1 and the replies | Findings; nothing is fixed. A defect (development-flow.md, section 2.3) asks the product owner to review. Every other finding is a row for the notes file. |
| 12. Merge | GitHub | When every required check passes; for a High card, or when round 2 found a defect, after the product owner's approval |

- **Notes file.** The notes of round 2 go in
  `tasks/EPIC-11-notes/<card>.md` (in general
  `tasks/<epic>-notes/<card>.md`), one file per card, with the columns
  Note, Level, Proposed fix, Priority, Decision (development-flow.md,
  section 2.4). The diff-review agent changes nothing, so it posts the
  rows on the pull request; the lead session or the code agent commits
  the file in the card's pull request. Decision stays empty until the
  epic closes.
- **Reviews on GitHub.** The product owner and Claude Code share one
  GitHub account, which cannot approve or request changes on its own
  pull request. The diff-review agent therefore posts plain review
  comments and a summary comment; the example commands are in
  `.claude/agents/diff-review-agent.md`.

## Branches, commits, and pull requests

From `../tripmate-docs/docs/development-flow.md`, section 2.5.

| What | Rule | Example |
|------|------|---------|
| Branch | `<type>/<ID>-<short-name>`; type is `feat`, `fix`, `refactor`, `test`, or `chore` | `feat/INV-01-create-invitation` |
| Commit message | Starts with the requirement ID, in English | `INV-01 Expire an Invitation after 7 days` |
| Pull request title | Starts with the requirement ID | `INV-01 Create an Invitation` |
| Pull request description | The card and task links, the risk level, what changed and what is left out, the case-to-test table with its failing and passing runs, decisions, and the test-check report | -- |

- A platform card with no requirement ID uses its card ID instead, for
  example `MF1 Add CI: Analyze, Test, and Android build`. This is the
  practice of this repository; development-flow.md does not write it
  yet.
- The task link points to the task in this repository, for example
  `tasks/EPIC-11.md#mf1`. The description also lists the task's manual
  checks with their results.
- `main` is protected: every change goes through a pull request, and
  the branch must be up to date with `main`.
- One card has one pull request per repository.
- A commit of the test agent carries the trailer `Agent: test`; no other
  commit does.
- Push only when the product owner says so. Never add the
  `human-approved` label.

## Agent roles

The four roles are in `.claude/agents/`
(`../tripmate-docs/docs/development-flow.md`, section 2.3):

| Role | Starts with | May change | Never |
|------|-------------|------------|-------|
| `test-agent` | The task, its spec sections, the pinned contract | Test files | Reads the code written for the card; makes up an expected result the task does not give |
| `code-agent` | The task, its spec sections, the test files, and later the review findings | Code, and tests of its own | Changes, skips, or deletes a test of the test agent; changes `tasks/<epic>.md`; reads another agent's conversation |
| `test-check-agent` | The task, the test files, the code, the test results | Nothing | Changes code or tests; reads another agent's conversation |
| `diff-review-agent` | The pull request's diff, the task, its spec sections | Nothing; it only posts on the pull request | Changes code or tests; reads another agent's conversation |

This file, the agent roles, and the CI workflow are High-risk files: a
pull request that changes them needs the product owner's approval
(`development-flow.md`, section 2.1).
