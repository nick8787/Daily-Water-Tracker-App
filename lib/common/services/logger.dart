import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:logging/logging.dart';

final log = Logger('EW');

/// Logs a caught exception via the app [Logger] ([LoggerBootstrapper])
void logCaughtError(
  String message,
  Object error, [
  StackTrace? stackTrace,
]) {
  log.severe(message, error, stackTrace);
}

/// Non-fatal issues (fallback paths, optional lookups)
void logCaughtWarning(
  String message,
  Object error, [
  StackTrace? stackTrace,
]) {
  log.warning(message, error, stackTrace);
}

class LoggerBootstrapper {
  Future<void> setupLogger() async {
    Logger.root.level = flutterFlavor.isProd ? Level.OFF : Level.ALL;
    Logger.root.onRecord.listen((record) {
      // It's used for printing in dev environment
      // ignore: avoid_print
      print(
        '${record.level.name}, ${record.time}, '
        'Msg: ${record.message}, '
        '${record.error != null ? 'Error: ${record.error}, ' : ''}'
        '${record.stackTrace != null ? 'StackTrace: ${record.stackTrace}' : ''}',
      );
    });

    if (flutterFlavor.isProd) {
      EasyLocalization.logger.enableBuildModes = [];
    }
  }
}
