import 'package:mobipkg_tools/mobipkg_tools.dart';

final globalOptions = GlobalOptions();

class GlobalOptions {
  var verbose = false;

  void initArgParser(ArgParser parser) {
    parser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show verbose output.',
      defaultsTo: false,
    );
  }

  void parseArgs(ArgResults result) {
    verbose = result['verbose'] as bool;
  }
}
