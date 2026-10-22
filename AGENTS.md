# AGENTS.md

## Project overview

Flutter workspace for viewing the "My School" (Моя школа / authedu.mosreg.ru)
schedule. The repository contains two apps and one shared Dart package:

| Path                       | Package           | What it is                                                        |
| -------------------------- | ----------------- | ----------------------------------------------------------------- |
| `packages/schedule_phone`  | `schedule_phone`  | Android phone app: ESIA login, token storage, token sync to watch |
| `packages/schedule_watch`  | `schedule_watch`  | Wear OS app: shows the current week's schedule                    |
| `packages/schedule_shared` | `schedule_shared` | API client, models, exceptions, Riverpod providers                |
| `api/`                     | —                 | `posting` request descriptions for the school API endpoints       |

There is no backend. Both apps talk directly to `https://authedu.mosreg.ru/api`.

### Data flow

1. The phone app starts an ESIA OAuth flow in the browser
   (`Api.loginUrl`). The callback comes back through the
   `lynx-schedule://tokenRedirect` deep link.
2. `TokensRepository` stores `token` / `refresh_token` in
   `SharedPreferences`. It is exposed through `tokensRepoProvider`.
3. The phone sends the token to the watch with
   `WatchConnectivity.updateApplicationContext({'token': ...})`.
4. `WatchSync` on the watch listens for that context and sets
   `tokenProvider` and `lessonOffsetProvider` (the bell offset configured on
   the phone).
5. `scheduleProvider` reads `tokenProvider`, creates `MySchoolApi(token)`,
   calls `getSchedule()`, and returns a `Schedule`.
6. The watch renders `Schedule.lessonsByDays` in a `PageView`, with the
   current weekday selected initially.

The phone also stores a bell offset in `SharedPreferences` and sends it as
`lessonOffsetSeconds`. On the watch the offset shifts both `startAt` and
`finishAt`: a negative value marks a lesson as current earlier, a positive
value later. Keep the phone and watch limits in sync (`maxLessonOffset`,
currently ±5 minutes).

`MySchoolApi` currently hardcodes the student id and requests the current
week (Monday through Saturday). There is no injected clock, so date-dependent
behavior is tied to `DateTime.now()`.

## Toolchain

- Flutter `^3.47.4` at the workspace root, Dart SDK `^3.13.3`.
- Pub workspace (`workspace:` in the root `pubspec.yaml`); the packages use
  `resolution: workspace`.
- Riverpod 3 (`flutter_riverpod`, `riverpod`), `dio`, `json_serializable`,
  `shared_preferences`, `watch_connectivity`, `workmanager`,
  `wear_os_plugin`, `app_links`.
- Lints: `package:lints/recommended.yaml` plus explicit rules in
  `analysis_options.yaml` (single quotes, const constructors/literals,
  explicit return types, no empty `else`).
- `import_sorter` is available in the root dev dependencies.

## Commands

Run commands from the repository root unless noted otherwise.

```bash
# Dependencies (workspace-wide)
flutter pub get

# Static analysis / formatting
flutter analyze
dart format .
dart fix --apply
dart run import_sorter:main        # optional; imports are already grouped

# JSON code generation (only in the shared package)
cd packages/schedule_shared
dart run build_runner build --delete-conflicting-outputs

# Run the apps
cd packages/schedule_phone && flutter run -d <device-id>
cd packages/schedule_watch && flutter run -d <device-id>

# Tests
cd packages/schedule_watch && flutter test
# or from the root:
flutter test packages/schedule_watch/test
```

Editor debug configs exist in `.vscode/launch.json` (phone/watch, debug/profile/
release) and `.zed/debug.json` (phone). The Flutter run target must be the
package directory, not the repository root.

### Code generation

`lesson.g.dart` and `mark.g.dart` are generated from the `@JsonSerializable`
models by `build_runner`. Do not edit them by hand. They are currently not
tracked in Git, so run `build_runner` in `packages/schedule_shared` after a
fresh clone or after changing a model.

## Architecture and conventions

### Packages and imports

- `schedule_shared/lib/schedule_shared.dart` is the package barrel and exports
  `api.dart`, `classes/classes.dart`, and `providers/providers.dart`.
- Keep folder barrels up to date: `classes.dart`, `providers.dart`,
  `screens.dart`, `widgets.dart`.
- Within a package, imports use `package:...` paths (for example
  `package:schedule_watch/screens/screens.dart`), including internal files.
  `always_use_package_imports` is disabled, but the existing code consistently
  uses package imports.
- Import order used in the codebase: `dart:` imports, blank line, `package:`
  imports, blank line, relative imports (when present). `import_sorter` is
  available if imports need regrouping; keep the existing grouping stable.

### Dart style

The code uses modern Dart 3.13 syntax deliberately. Follow the surrounding
style instead of rewriting it into older Dart:

- Primary constructors are used, for example
  `class TokensRepository(final SharedPreferences _prefs)` and
  `class Mark(final String value, {...})`, including in-body initializers
  such as `this : assert(startAt.isBefore(finishAt));` in `Lesson`.
- Dot shorthands: `fieldRename: .snake`, `colorScheme: .fromSeed(...)`,
  `absenceReason: .none`, `mainAxisSize: .min`, `textAlign: .center`.
- Pattern matching and switch expressions, for example
  `switch (response.statusCode!)`, `if (queryParams case {'code': final code})`,
  and `when` guards.
- Single quotes, two-space indentation, trailing commas, `const` wherever
  possible, explicit return types on functions and getters.
- Prefer `final` fields and immutable models. `Lesson` and `Mark` are immutable
  and expose `copyWith` / `toJson` where needed.
- Models use snake_case JSON via `@JsonSerializable(fieldRename: .snake)` and
  `@JsonKey(name: ...)` for irregular names.
- UI strings are in Russian; log messages and code identifiers are in English.
- Use `dart:developer`'s `log(..., name: '...')` for diagnostics rather than
  `print`.

### Riverpod

- Providers live in `schedule_shared` (`tokenProvider`, `scheduleProvider`) or
  in the app package (`tokensRepoProvider` in the phone).
- `scheduleProvider` is a `FutureProvider`; it throws `TokenNotFound` when
  there is no token and does not retry `TokenException`s. Keep this behavior:
  the watch relies on the exception type to show `TokenScreen`.
- Use `ref.watch` in `build`, `ref.read` in callbacks, and invalidate the
  relevant provider after mutations.
- The watch app intentionally does not install `RiverpodDevToolsObserver` in
  its entrypoint (it slowed cold start).

### Widgets

- The watch UI is built from `LessonWidget`, `WatchWidget`, `EmptyScreen`, and
  `OneDaySchedule` (`ScheduleScreen`). Timers update the clock and lesson
  highlighting without rebuilding the whole page.
- Current-lesson highlighting and auto-scrolling are behavior covered by
  `LessonWidget` / `OneDaySchedule`; keep them working when changing the
  schedule list.

## Testing

- Widget tests live in `packages/schedule_watch/test/`.
- `lesson_widget_test.dart` uses a `LessonMock` extension on `Lesson` to build
  test data. Follow that pattern for new lesson/widget tests.
- Use `testWidgets` + `WidgetTester.pumpWidget`, and assert on visible text or
  widget properties (`find.text`, `find.byType`).
- Add tests for schedule grouping, current-lesson detection, mark/absence
  rendering, and token-error handling when changing those areas.

## Git message style

The history does **not** use Conventional Commits. Match the existing style:

```text
Area: imperative summary
```

- `Area` is one of `Watch`, `Phone`, `Shared`, `Core`, or a backticked class /
  component name such as `` `ScheduleScreen` `` or `` `LessonWidget` ``.
- Use an imperative verb: `add`, `fix`, `update`, `remove`, `change`,
  `implement`. Recent commits use lowercase after the colon.
- Keep the subject short (roughly <= 72 characters), no trailing period.
- Separate the subject from the body with a blank line.
- Explain **why** in the body: the problem, symptom, or constraint first.
  Then list concrete changes as `-` bullets. Wrap lines around 72–80 chars.
- Put identifiers, paths, and symbols in backticks.
- One logical change per commit. Do not mix app and shared changes unless they
  are required for the same behavior.

Examples from the repository:

```text
Watch: fix slow cold start

A cold start took about a minute because riverpod retries failed
providers ~38 s in total

- add `TokenException` base class and `TokenNotFound` for the missing
  token case
- throw `TokenNotFound` instead of `TokenInvalidException` when there is
  no token
- disable retries for `TokenException`, limit other errors to 5 attempts
  (~6 s)
```

```text
Shared: add `DetailedMark` and `MySchoolApi.getMarks`
- Extend `Mark` base class with some fields and `toMap` method
- Add `DetailedMark extends Mark` with date, subject
- Implement `MySchoolApi.getMarks` returning `List<DetailedMark>`
```

```text
Watch: fix abrupt page change when a lesson is current
- scroll only the nearest vertical scrollable via
  `Scrollable.maybeOf(context, axis: Axis.vertical)`
```

## Gotchas

- `posting.env` and other `*.env` files contain secrets and are ignored. Never
  commit tokens. The `api/*.posting.yaml` files use `${BASE_URL}` / `${AUTH}`.
- The deep link scheme is `lynx-schedule`; it is registered in
  `packages/schedule_phone/android/app/src/main/AndroidManifest.xml`.
- `Tokens.isValid` only checks the `eyJhb` JWT prefix. Do not weaken or bypass
  this check without updating the UI hints and tests.
- Launcher icons are generated from the root `icon.png`; run
  `dart run flutter_launcher_icons` from a package directory that defines the
  `flutter_launcher_icons` config.
- Workmanager scheduling in `packages/schedule_watch/lib/main.dart` is currently
  commented out, and `calculateAndSaveNextLesson` writes a placeholder. Do not
  assume background updates run.
- `build/`, `.dart_tool/`, and `packages/schedule_watch/.widget_preview/` are
  generated output; do not edit them as source.
- The working tree may contain uncommitted changes. Inspect `git status` and
  avoid overwriting unrelated work.
