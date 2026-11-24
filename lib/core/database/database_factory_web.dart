import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Register SQLite Web before the first database access.
Future<void> configureDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}
