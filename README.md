# tripmate-mobile
TripMate Mobile client (Flutter)

One Flutter app for Android and iOS, in two flavors that install side
by side: `dev` ("TripMate Dev", `com.tripmate.app.dev`) and `prod`
("TripMate", `com.tripmate.app`).

```sh
flutter pub get
flutter run --flavor dev                              # against the local stack
flutter run --flavor dev --dart-define=API_MODE=mock  # mock mode
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Flutter is pinned to 3.38.5. Setup, every command, and the coding
conventions are in [CLAUDE.md](CLAUDE.md). Product documents live in
the [tripmate-docs](../tripmate-docs/) repository, cloned next to this
one.
