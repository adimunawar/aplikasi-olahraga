# PANDUAN ARSITEKTUR & DESIGN PATTERN (FLUTTER)
**Aplikasi Olahraga Rumah (Program 30 Hari - Hipertrofi & Kekuatan)**

Dokumen ini adalah **pedoman arsitektur wajib** untuk seluruh pengembangan kode di repositori ini. Setiap penambahan fitur, refaktor, maupun perbaikan bug **harus mematuhi aturan dan pola desain** yang tercantum di sini.

---

## 1. Filosofi & Pola Arsitektur Utama

Aplikasi ini menggunakan pola **Feature-First Layered Architecture** yang dikombinasikan dengan prinsip **Clean Architecture & Riverpod 2.x (Unidirectional Data Flow)**.

### Diagram Alur Data (*Unidirectional Data Flow*)

```
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│   • Widgets / Screens (UI Murni - Stateless / Consumer)│
│   • Controllers / Notifiers (Riverpod State)           │
└───────────────────────────▲────────────────────────────┘
                            │ (State / Events)
┌───────────────────────────┴────────────────────────────┐
│                    APPLICATION LAYER                   │
│   • Services / Use Cases (Logika Bisnis & Komputasi):  │
│     TargetCalculator, StreakEngine, RestTimerService   │
└───────────────────────────▲────────────────────────────┘
                            │ (Domain Entities)
┌───────────────────────────┴────────────────────────────┐
│                      DOMAIN LAYER                      │
│   • Models / Entities (Immutable Data Classes)         │
│   • Value Objects, Enums (WorkoutType, Difficulty)     │
│   • Abstract Repository Interfaces                     │
└───────────────────────────▲────────────────────────────┘
                            │ (Raw Data Mapping)
┌───────────────────────────┴────────────────────────────┐
│                       DATA LAYER                       │
│   • Repository Implementations                         │
│   • Data Sources:                                      │
│     - AssetDataSource (baca JSON statis)               │
│     - LocalStorageSource (SQLite / SharedPreferences)  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Aturan Tiap Lapisan (*Layer Rules*)

### A. Presentation Layer (`features/<feature>/presentation/`)
- **Tanggung Jawab**: Menampilkan antarmuka pengguna dan menangkap input interaksi.
- **Aturan**:
  1. Widget **tidak boleh** mengakses database, `SharedPreferences`, atau file JSON secara langsung.
  2. Widget hanya boleh berinteraksi dengan **Controller / Notifier** melalui Riverpod (`ref.watch` atau `ref.read`).
  3. Hindari logika bisnis di dalam `build()` method atau `setState`.
  4. Semua warna, font, dan padding **wajib** menggunakan token dari `core/theme/` (`AppColors`, `AppTypography`, `AppTheme`). Dilarang *hardcoded* kode heksadesimal (`Color(0xFF...)`) langsung di dalam widget.
  5. Target sentuh minimal tombol adalah **48x48 px** (ergonomis untuk olahraga).

### B. Application Layer (`features/<feature>/application/`)
- **Tanggung Jawab**: Orkestrasi logika bisnis kompleks lintas repositori dan komputasi murni.
- **Contoh**:
  - `TargetCalculationService`: Menghitung target repetisi mingguan berdasarkan hasil tes kemampuan: $\max(3, \text{round}(\text{tes} \times \text{faktor}))$.
  - `StreakCalculationService`: Menghitung streak aktif tanpa memutus streak di hari istirahat.
  - `ProteinRecommendationEngine`: Mesin kombinasi makanan murah lokal ($\pm 3\text{ g}$).
- **Aturan**: Lapisan ini berupa kelas Dart murni (*pure Dart*), mudah diuji (*unit test*) tanpa perlu mock Flutter widget.

### C. Domain Layer (`features/<feature>/domain/`)
- **Tanggung Jawab**: Mendefinisikan entitas data bisnis, value objects, dan kontrak repositori (*interface*).
- **Aturan**:
  1. Semua entity harus bersifat **immutable** (`final fields`, menyediakan method `copyWith`).
  2. Lapisan Domain **tidak boleh** bergantung pada lapisan lain (bebas dari dependensi UI atau Data).
  3. Deklarasi interface repositori berada di sini (misal: `abstract class ExerciseRepository`).

### D. Data Layer (`features/<feature>/data/`)
- **Tanggung Jawab**: Mengambil data mentah (JSON aset, SQLite, SharedPreferences), melakukan serialisasi/deserialisasi, dan mengimplementasikan antarmuka repositori dari Domain.
- **Aturan**:
  1. Mengisolasi pemanggilan I/O lokal.
  2. Mengonversi data mentah (DTO / Map JSON) menjadi Domain Entity sebelum diteruskan ke atas.
  3. Menangani *error handling* / fallback bila data lokal kosong atau korup.

---

## 3. Struktur Direktori Standar

Setiap fitur dikelompokkan secara mandiri di dalam folder `lib/features/`:

```
lib/
├── app.dart                                # MaterialApp, Routing, Root Theme
├── main.dart                               # Entry point, ProviderScope
│
├── core/                                   # Komponen global / lintas fitur
│   ├── constants/                          # Global enums (WorkoutType, Language, Theme)
│   ├── theme/                              # AppColors, AppTypography, AppTheme
│   ├── database/                           # Inisialisasi DB lokal & Key-Value storage
│   ├── services/                           # WakelockService, Sound/HapticService
│   └── utils/                              # Formatters, DateTime helper
│
└── features/
    ├── exercises/                          # Pustaka & Master Data Gerakan
    │   ├── data/                           # ExerciseAssetDataSource, ExerciseRepositoryImpl
    │   ├── domain/                         # Exercise, MuscleGroup, ExerciseVariation
    │   └── presentation/                   # ExerciseDetailScreen, ExerciseLoopLooper
    │
    ├── program/                            # Jadwal Program 30 Hari & Kalender
    │   ├── data/                           # ProgramRepositoryImpl
    │   ├── domain/                         # ProgramDay, DayOverride
    │   ├── application/                    # ProgramTargetCalculator (rumus PRD)
    │   └── presentation/                   # CalendarScreen, DaySummaryCard
    │
    ├── onboarding/                         # Profil, PAR-Q & Tes Kemampuan
    │   ├── data/                           # UserProfileRepository
    │   ├── domain/                         # UserProfile, ReadinessQuestion, FitnessTestResult
    │   └── presentation/                   # ProfileStep, QuestionnaireStep, FitnessTestStep
    │
    ├── workout_session/                    # Sesi Latihan Aktif
    │   ├── data/                           # SessionRepository
    │   ├── domain/                         # WorkoutSession, SetLog
    │   ├── application/                    # RestTimerService
    │   └── presentation/                   # ActiveSessionScreen, RestTimerWidget
    │
    ├── progress/                           # Progres, Streak, Lingkar Badan & Foto
    │   ├── data/                           # MeasurementRepository, PhotoStorageService
    │   ├── domain/                         # BodyMeasurement, ProgressPhoto
    │   └── presentation/                   # ProgressScreen, MeasurementChart
    │
    └── nutrition/ (v1.1)                   # Panduan Protein Harian
        ├── data/                           # FoodRepository, FoodLogRepository
        ├── domain/                         # FoodItem, ProteinTarget
        ├── application/                    # LocalProteinRecommenderEngine
        └── presentation/                   # ProteinCardWidget, QuickAddChip
```

---

## 4. Standar State Management (Riverpod 2.x)

1. **Provider Scope**: `runApp` wajib dibungkus dengan `ProviderScope`.
2. **State Immutability**: Jangan pernah memutasi state secara langsung. Selalu gunakan `state = state.copyWith(...)` atau hasil kalkulasi baru.
3. **Pemisahan Notifier**:
   - Gunakan `Notifier` / `AsyncNotifier` untuk state yang memiliki interaksi pengguna.
   - Gunakan `Provider` sederhana untuk dependency injection (Repository, Service).
4. **Pembersihan Resource**: Kontroller animasi, timer countdown, dan audio player wajib memiliki mekanisme `dispose()` atau auto-dispose.

---

## 5. Standar Desain Visual ("Obsidian Kinetic")

1. **Warna Dasar**: Kanvas gelap pekat (`#0D0E11` dan `#121316`).
2. **Aksen Interaktif**: *Electric Lime* (`#CCFF00`) untuk CTA utama dan hari aktif.
3. **Kode Sesi Standar**:
   - `P` (Dorong): `#CCFF00`
   - `K` (Kaki): `#10B981`
   - `C` (Core): `#F59E0B`
   - `F` (Full Body): `#C084FC`
   - `R` (Istirahat): `#64748B`
4. **Tipografi Wajib**:
   - Angka metrik, timer, judul layar: **Barlow Condensed** (dengan `FontFeature.tabularFigures()` pada timer).
   - Penjelasan form, deskripsi anatomi, label tombol: **Plus Jakarta Sans**.

---

## 6. Standar Offline-First & Privasi Data

1. **Zero Cloud Requirement**: Tidak boleh ada dependensi API eksternal atau backend untuk fungsi inti aplikasi.
2. **Foto Progres Privat**: Foto lingkar badan & progres disimpan di direktori privat aplikasi (`getApplicationDocumentsDirectory()`), **dilarang menyimpannya ke galeri publik perangkat** tanpa izin pengguna.
3. **Integritas Analisa**: Setiap perubahan kode wajib lulus `flutter analyze` dengan **0 warning dan 0 error**.

