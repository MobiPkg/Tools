import 'dart:async';

import 'package:args/command_runner.dart';

abstract class BaseCommand extends Command<void> {
  @override
  FutureOr<void>? run();
}
