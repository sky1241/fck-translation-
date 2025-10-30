import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Logger utility to replace print statements
/// Uses debugPrint in debug mode, does nothing in release
class Logger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[App] $message');
    }
  }

  static void info(String message) => log('INFO: $message');
  static void warning(String message) => log('WARN: $message');
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    log('ERROR: $message');
    if (error != null && kDebugMode) {
      debugPrint('  Error: $error');
      if (stackTrace != null) {
        debugPrint('  Stack: $stackTrace');
      }
    }
  }
}

