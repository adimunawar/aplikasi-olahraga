# Flutter Web Local Database

The app uses one `sqflite` API for Android/iOS and Flutter Web.

- Android/iOS: native SQLite through `sqflite`.
- Web: SQLite compiled to WebAssembly; database bytes are persisted in IndexedDB through `sqflite_common_ffi_web`.

## First-time setup

Run these commands from the repository root (the directory containing `pubspec.yaml`):

```bash
flutter pub get
dart run sqflite_common_ffi_web:setup
```

The setup command generates these required runtime assets beside `web/index.html`:

- `web/sqlite3.wasm`
- `web/sqflite_sw.js`

Keep both generated files in source control, or regenerate them before every Web build. The CI Web build job runs the setup command automatically.

After upgrading `sqflite_common_ffi_web`, `sqflite_common_ffi`, `sqflite_common`, or `sqlite3`, regenerate the assets. Use `dart run sqflite_common_ffi_web:setup --force` if the cached worker must be rebuilt.

## Run locally

Use a stable origin/port so the browser keeps using the same IndexedDB database:

```bash
flutter run -d chrome --web-port 8080
```

Browser storage is scoped to the origin. Changing the port creates a different origin and therefore appears to use a fresh database.

## Implementation

`main.dart` configures the platform database factory before the first database access:

- Web selects `databaseFactoryFfiWeb`.
- Native platforms keep the factory registered by `sqflite`.

Feature repositories and `AppDatabase` continue using the normal `sqflite` API. Do not create a second Web-only repository implementation.

## Important limitations

- Web support is experimental and can be slower than native SQLite.
- Web database names are virtual names, not filesystem paths. `getDatabasesPath()` returns `/`.
- Persistent Web databases must use the default single-instance connection. Do not set `singleInstance: false`.
- The implementation uses a shared worker where supported. Some browsers (including Android Chrome fallback scenarios) may use a basic worker, which is not cross-tab safe.
- Browser data can be cleared by the user or browser storage policies. Do not treat IndexedDB as a replacement for cloud backup/synchronization.
