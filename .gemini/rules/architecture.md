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
5. **Kualitas Kode**: Sebelum menyelesaikan tugas, pastikan `flutter analyze` menghasilkan **0 issues (No issues found)**.

