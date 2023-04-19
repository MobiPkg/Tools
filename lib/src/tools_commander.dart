import 'package:args/command_runner.dart';
import 'package:mobipkg_tools/mobipkg_tools.dart';

class ToolsCommander {
  FutureOr<void> run(List<String> arguments) async {
    final CommandRunner<void> runner = CommandRunner<void>(
      'mobipkg_tools',
      'A set of tools for MobiPkg.',
    );

    runner.addCommand(DepCommand());

    await runner.run(arguments);
  }
}
