import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

class DatabaseInit {
  /// Initialize database for all platforms
  static Future<void> initialize() async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }
}
