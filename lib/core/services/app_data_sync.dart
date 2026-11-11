import 'package:flutter/foundation.dart';

/// Centralized Data Synchronization Notifier
/// Memastikan ketika ada perubahan pada Profil, Jadwal, Program, atau Sesi Latihan,
/// seluruh halaman aktif (Home, Plans, Progress, Profile) langsung melakukan sinkronisasi otomatis.
class AppDataSync {
  static final AppDataSync instance = AppDataSync._();
  AppDataSync._();

  final ValueNotifier<int> dataRevision = ValueNotifier<int>(0);

  void notifyDataChanged() {
    dataRevision.value++;
  }
}

