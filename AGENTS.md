# Repository Guidelines

## Project Structure & Module Organization
- `app/` holds the Flutter client; core code lives in `app/lib/` with feature folders like `home/`, `login/`, `todo/`, shared utilities under `shared/` and `utils/`.
- UI assets reside in `app/assets/`; update `pubspec.yaml` when adding new ones. Generated build artifacts stay in `app/build/`—do not edit by hand.
- Tests live in `app/test/`; mirror the `lib/` structure and name files with `_test.dart`.
- Platform scaffolding is under `app/android/`, `app/ios/`, and `app/web/`; only touch when changing platform configuration.
- `services/` is reserved for backend/service code; keep it decoupled from Flutter UI concerns.

## Build, Test, and Development Commands
- Install deps: `cd app && flutter pub get`.
- Static analysis: `flutter analyze` (uses Flutter lints) to catch style and API issues.
- Format: `dart format lib test` for consistent whitespace before committing.
- Run tests: `flutter test` or with coverage `flutter test --coverage`.
- Local dev: `flutter run` for device/emulator; `./run.sh` serves the web build on port 5000.
- Release build: `flutter build apk --release` (adjust target platform as needed).

## Coding Style & Naming Conventions
- Follow Dart defaults: 2-space indent, `lower_snake_case.dart` filenames, `PascalCase` for types, `lowerCamelCase` for vars/functions.
- Prefer `const` constructors and widgets where possible; avoid `print` in favor of logging or error reporting.
- Align with `analysis_options.yaml` (includes `flutter_lints`); fix or intentionally silence lints with inline `ignore` only when justified.

## Testing Guidelines
- Use `flutter_test` with `_test.dart` suffix; co-locate tests to mirror `lib/` paths (e.g., `lib/shared/foo.dart` → `test/shared/foo_test.dart`).
- Aim to cover widget states and date/utility logic; add golden tests for visual regressions when changing UI layouts.
- Keep tests deterministic; avoid real network calls and external state.

## Commit & Pull Request Guidelines
- Commit messages: concise, present-tense summaries (e.g., “Add lunar calendar converter”), reference issues with `#ID` when applicable.
- Before opening a PR: run `flutter format`, `flutter analyze`, and `flutter test`; include a brief description, screenshots for UI changes, and manual verification notes.
- Keep PRs scoped to a single concern; note any follow-ups or TODOs in the description rather than leaving stray code comments.

## Security & Configuration Tips
- Do not commit secrets or API keys; prefer `--dart-define` for runtime values (`run.sh` shows the pattern).
- Regenerate platform files (`android/`, `ios/`, `web/`) only when necessary; review diffs carefully before pushing.***
