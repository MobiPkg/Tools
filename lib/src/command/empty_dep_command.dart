import 'package:mobipkg_tools/mobipkg_tools.dart';

class EmptyDepCommand extends BaseVoidCommand {
  @override
  final name = 'empty-dep';

  @override
  final description = 'Find empty dependencies in cache.';

  @override
  void initParser(ArgParser argParser) {}

  @override
  FutureOr<void>? run() async {
    final deps = Dep.findEmptyDependenciesInCache();

    final buffer = StringBuffer();
    buffer.writeln('Found empty dependencies:');
    for (final dep in deps) {
      buffer.write('  ');
      buffer.writeln(dep.name);
    }

    buffer.writeln('\nFound ${deps.length} empty dependencies.');

    logger.info(buffer.toString());
  }
}
