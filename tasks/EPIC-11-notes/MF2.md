# MF2 API client and mock mode -- Round 2 Notes

**Card:** MF2, [tasks/EPIC-11.md](../EPIC-11.md#mf2)\
**Pull request:** https://github.com/huynguyennang-agilityio/tripmate-mobile/pull/6\
**Round 2:** since `c0f1600`, head `0c466d1`

The findings of the second diff review round that are not defects
([development-flow.md](https://github.com/huynguyennang-agilityio/tripmate-docs/blob/main/docs/development-flow.md),
section 2.4). The Decision column stays empty until the epic closes.

Round 2 also found one defect, R2-12: the contracts tool did not exit
after a failed download (Maven Central answered HTTP 429 in CI run
45971240244), so the `Contracts` job hung until its timeout. It is fixed
in this pull request at commit `0d8b9dc` after the product owner asked
for it, so it is not a note.

| Note | Level | Proposed fix | Priority | Decision |
|------|-------|--------------|----------|----------|
| R2-1: `.github/risk-paths.toml:105`: `lib/app/**` (flavors, `API_MODE`) matches only `lib/**` and is Low; the `lib/app/**` half of R1-3 was not answered | Repository | Add a High rule `lib/app/**` (or `lib/app/api_mode.dart` and `lib/app/flavor.dart`) with reason "Flavors and the API mode every build uses", or write down why it stays Low | Low | |
| R2-2: `.github/workflows/ci.yml:21` still says "Change both together" and `flow.yml:36` says "all three", while CLAUDE.md says three places and four values | Repository | Make both comments name `pubspec.yaml` (`sdk:`, `flutter:`), `ci.yml` `FLUTTER_VERSION`, and `flow.yml` `--branch`, "change all four values together" | Low | |
| R2-3: `.github/workflows/ci.yml:30` and the other steps: `actions/checkout` v4.4.0 and `actions/setup-java` v4.9.1 run on the deprecated Node 20 | Repository | Pin both to the full SHA of their current major (checkout as in `tripmate-contracts`, v7.0.1), version in the comment | Low | |
| R2-4: `lib/core/api/mock_api.dart:142`: the round 1 fixes have no test (no-content answer, `checkApiConfig` / `https://` check, `DeviceIdStore.ensureSaved`, `CONTRACTS_SHA` mismatch and missing lock) | Repository | Add code-agent tests in new files: a `204` with no content resolves with status 204 and `data == null`; `ensureSaved` leaves the id in `SharedPreferences`; `contracts.dart check` with a wrong `CONTRACTS_SHA` exits 2; make `baseUrlFor` testable with an override parameter | Medium | |
| R2-5: `lib/core/api/api_client.dart:22`: a mock-mode `prod` build with an `http://` `API_BASE_URL` now throws when the Dio is built, though mock mode sends no request | Repository | Apply the `https://` rule only in real mode: move it into `checkApiConfig`, or pass the mode to `baseUrlFor` | Low | |
| R2-6: `lib/main.dart:11` / `lib/features/health/logic/health_cubit.dart`: `HealthFailed.error` is still shown and logged nowhere (second half of R1-7) | Repository | `debugPrint` the error in `HealthCubit.load`'s `catch`, or show `error.toString()` on the test screen | Low | |
| R2-7: `lib/core/api/device_id.dart:27`: a failed save of the device id (throw or `false`) is swallowed silently | Repository | Keep it non-fatal but `debugPrint` when the write throws or returns `false` | Low | |
| R2-8: `tool/contracts.dart:485`: a download that fails during `response.pipe` leaves its per-run `.part` file in the cache; each failed run adds one | Repository | Fixed in `0d8b9dc` with R2-12 | Low | |
| R2-9: `.github/risk-paths.toml:75`: the test lock still only knows `conftest.py`, so a code commit adding `test/flutter_test_config.dart` passes `flow / test-lock` (only the risk gate catches it) | Project | In `tripmate-backend` `flowchecks`, add a `hook-file-pattern` input the test lock treats like `conftest.py`; pass `(^|/)flutter_test_config\.dart$\|(^|/)dart_test\.yaml$` from `flow.yml`; move the pins of `flow.yml` and `risk-gate.yml` | Medium | |
| R2-10: `CLAUDE.md:162`: the per-action `Idempotency-Key` helper is left to "the first card with a create screen", but no task says so (spec 2.11: "kept for retries of the same action") | Epic | Add to the first EPIC-01 Mobile task with a create: a helper making one UUID per user action, passed as `Options(headers: {IdempotencyKeyInterceptor.header: key})`, and a test that "Try again" sends the same key | Medium | |
| R2-11: `CLAUDE.md:215`: `main` requires only `Analyze`, `Test`, `Android build`; the Done when needs `Contracts`, `flow / failing-first`, `flow / test-lock`, `gate / risk-gate` required | Epic | Product owner adds the four checks to `main`'s protection right after the merge (never `flow / risk-gate`), confirms `gate / risk-gate` runs on the next pull request, and records it as a manual check of MF2 | High | |
