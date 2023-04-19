import 'package:mobipkg_tools/mobipkg_tools.dart';

class DepCommand extends BaseCommand {
  @override
  String get description => 'Show dependencies of a package.';

  @override
  String get name => 'dep';

  @override
  FutureOr<void>? run() async {
    final rest = argResults?.rest;

    if (rest == null || rest.isEmpty) {
      print('Please specify a package name.');
      return;
    }

    for (final String packageName in rest) {
      final Set<String> depSet = {};
      final deps = DepFinder(packageName).find();
      depSet.addAll(deps);
      logger.info('Dependencies: \n${depSet.map((e) => '  $e').join('\n')}');
    }
  }
}
