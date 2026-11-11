---
description: Aturan Arsitektur & Pola Desain Wajib untuk Aplikasi Olahraga Rumah
globs: lib/**/*.dart, test/**/*.dart
---

# Aturan Arsitektur & Desain Wajib

Setiap perubahan atau pembuatan kode di proyek ini **WAJIB** mengikuti panduan yang telah ditetapkan di `ARCHITECTURE.md`:

1. **Pola Arsitektur**: Terapkan **Feature-First Layered Architecture** (Presentation, Application, Domain, Data) untuk setiap fitur di dalam folder `lib/features/<nama_fitur>/`.
2. **Pemisahan Lapisan**:
   - Widget dilarang mengakses I/O, database, SharedPreferences, atau JSON secara langsung. Harus melalui Riverpod Notifier / Controller.
   - Lapisan Domain harus murni Dart dan immutable.
   - Lapisan Application menangani rumus dan logika bisnis (seperti TargetCalculator, StreakEngine).
3. **Desain Sistem & Token**:
   - Selalu gunakan `AppColors`, `AppTypography`, dan `AppTheme` dari `lib/core/theme/`. Dilarang hardcoding warna hex atau font ad-hoc di dalam widget.
   - Font metrik dan timer wajib `Barlow Condensed` (dengan tabular figures). Font body wajib `Plus Jakarta Sans`.
4. **State Management**: Gunakan Riverpod 2.x dengan immutable state.
5. **Prinsip DRY (Don't Repeat Yourself) & Komponen Global Reusable (`lib/core/widgets/core_widgets.dart`)**:
   - Dilarang keras menduplikasi styling widget umum secara berulang-ulang di berbagai layar.
   - **Tombol**: WAJIB menggunakan [`AppButton`](file:///d:/ADI/aplikasi-olahraga/lib/core/widgets/app_button.dart) (`AppButton.primary`, `AppButton.secondary`, `AppButton.outline`). Dilarang menulis styling `ElevatedButton.styleFrom` ad-hoc secara manual di widget.
   - **Gambar**: WAJIB menggunakan [`AppSmartImage`](file:///d:/ADI/aplikasi-olahraga/lib/core/widgets/app_smart_image.dart) yang secara otomatis mendeteksi URL cloud (`http/https`) vs file lokal (`assets/`) tanpa menyebabkan error loop atau kedipan layar.
   - **Header Bagian / Section**: WAJIB menggunakan [`AppSectionHeader`](file:///d:/ADI/aplikasi-olahraga/lib/core/widgets/app_section_header.dart) untuk kombinasi icon + judul + tombol aksi trailing ("See All" / Subtitle info).
   - **Kartu & Kontainer**: WAJIB menggunakan [`AppCard`](file:///d:/ADI/aplikasi-olahraga/lib/core/widgets/app_card.dart) atau [`AppCard.tinted`](file:///d:/ADI/aplikasi-olahraga/lib/core/widgets/app_card.dart) untuk kontainer seragam beradius 18/20 dp, border lembut, dan shadow standar.
   - **Badges & Label**: WAJIB menggunakan [`AppBadge`](file:///d:/ADI/aplikasi-olahraga/lib/core/widgets/app_badge.dart) (`AppBadge.currentPlan`, `AppBadge.category`, `AppBadge.difficulty`).
6. **Navigasi & Routing**:
   - WAJIB menggunakan **GoRouter** melalui `appRouterProvider` (`lib/core/router/app_router.dart`).
   - Dilarang keras menggunakan `Navigator.push(MaterialPageRoute(...))` secara ad-hoc.
   - Gunakan `context.push(AppRoutes.<name>, extra: ...)` atau `context.go(AppRoutes.<name>)` dan `context.pop()`.
   - Bottom navigation dikelola melalui `StatefulShellRoute.indexedStack` di dalam `HomeScaffold`.
7. **Kualitas Kode**: Pastikan penulisan kode bersih, tipe data sesuai, dan impor valid melalui inspeksi kode yang teliti. DILARANG menjalankan perintah berat seperti `flutter analyze` atau `dart analyze` secara otomatis setiap kali selesai mengedit file (karena prosesnya berat dan memakan waktu). Jalankan perintah analisis HANYA jika diminta secara eksplisit oleh pengguna.

