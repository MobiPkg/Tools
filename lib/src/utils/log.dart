import 'package:logger/logger.dart';
import 'package:mobipkg_tools/mobipkg_tools.dart';

mixin LogMixin {
  late final w = logger.w;
  late final e = logger.e;
  late final i = logger.i;
  late final d = logger.d;
  late final v = logger.v;
  late final wtf = logger.wtf;
  late final log = logger.log;
}

Logger get logger => Logger(
      level: globalOptions.verbose ? Level.verbose : Level.info,
      printer: PrettyPrinter(
        methodCount: 3,
        errorMethodCount: 10,
        printTime: true,
        // noBoxingByDefault: true,
      ),
      filter: ProductionFilter(),
      // filter: DevelopmentFilter(),
      output: ConsoleOutput(),
    );

typedef CCLoggerFunction = void Function(
  dynamic message, [
  dynamic error,
  StackTrace? stackTrace,
]);

extension CCLoggerExt on Logger {
  CCLoggerFunction get verbose => v;
  CCLoggerFunction get debug => d;
  CCLoggerFunction get info => i;
  CCLoggerFunction get warning => w;
  CCLoggerFunction get error => e;
}
