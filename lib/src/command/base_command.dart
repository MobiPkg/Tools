import 'package:args/command_runner.dart';
import 'package:mobipkg_tools/mobipkg_tools.dart';

abstract class BaseVoidCommand extends Command<void> {
  BaseVoidCommand() {
    initParser(argParser);
  }

  @override
  FutureOr<void>? run();

  void initParser(ArgParser argParser) {}

  @override
  ArgResults get argResults {
    if (super.argResults == null) {
      throw Exception('argResults is null');
    }
    return super.argResults!;
  }
}
