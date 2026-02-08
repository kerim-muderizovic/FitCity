# UI (Flutter)

Flutter source used for both mobile and desktop entrypoints.

## Entry points
- Mobile: `lib/main_mobile.dart`
- Desktop: `lib/main_desktop.dart`

## Configuration
- API base URLs: `assets/config/app_config.json`
- Optional override:
  - `--dart-define=FITCITY_API_BASE_URL=http://localhost:8081`
- Release APK builds should always provide `FITCITY_API_BASE_URL` to avoid emulator-only defaults.

## Common commands
- `flutter pub get`
- `flutter analyze`
- `flutter test`
