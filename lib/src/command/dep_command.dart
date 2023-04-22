import 'dart:convert';

import 'package:mobipkg_tools/mobipkg_tools.dart';

class DepCommand extends BaseVoidCommand {
  @override
  String get description => 'Show dependencies of a package.';

  @override
  String get name => 'dep';

  @override
  void initParser(ArgParser argParser) {
    super.initParser(argParser);

    argParser.addFlag(
      'tree',
      abbr: 't',
      help: 'Show dependencies in tree format.',
      defaultsTo: false,
    );

    argParser.addFlag(
      'json',
      abbr: 'j',
      help: 'Show dependencies in json format.',
      defaultsTo: false,
    );

    argParser.addFlag(
      'first',
      abbr: 'f',
      help: 'Just show first level dependencies.',
      defaultsTo: true,
    );
  }

  @override
  FutureOr<void>? run() async {
    final rest = argResults.rest;

    if (rest.isEmpty) {
      print('Please specify a package name.');
      return;
    }

    final tree = argResults['tree'] as bool;
    final json = argResults['json'] as bool;
    final firstLevel = argResults['first'] as bool;

    if (tree && json) {
      print('Please specify only one format.');
      return;
    }

    for (final String packageName in rest) {
      final deps = DepFinder(packageName).find();

      if (tree) {
        _printTree(packageName, deps, firstLevel);
      } else if (json) {
        _printJson(packageName, deps, firstLevel);
      } else {
        _printDeps(packageName, deps, firstLevel);
      }
    }
  }

  void _printJson(String packageName, Set<Dep> deps, bool firstLevel) {
    final map = <String, dynamic>{};
    for (final dep in deps) {
      map[dep.name] = dep.toJson();
    }

    final text = JsonEncoder.withIndent('  ').convert(map);
    print(text);
  }

  void _printTree(String packageName, Set<Dep> deps, bool firstLevel) {
    final buffer = StringBuffer();
    buffer.writeln('Package: $packageName');
    buffer.writeln('Dependencies:');
    buffer.writeln();

    Set<String> pickedDeps = {};

    for (final dep in deps) {
      buffer.write(dep.treeString(alreadyPrinted: pickedDeps));
    }

    buffer.writeln('\nCount of dependencies: ${pickedDeps.length}');

    logger.info(buffer.toString().trim());
  }

  void _printDeps(String packageName, Set<Dep> deps, bool firstLevel) {
    final Set<String> names = {};

    void addDep(Dep dep) {
      if (names.contains(dep.name)) {
        return;
      }
      names.add(dep.name);
      dep.deps.forEach(addDep);
    }

    for (final dep in deps) {
      addDep(dep);
    }

    final buffer = StringBuffer();
    buffer.writeln('Package: $packageName');
    buffer.writeln('List:');
    buffer.writeln();
    for (final name in names) {
      buffer.writeln('  $name');
    }
    buffer.writeln();
    buffer.writeln('Dependencies: ${names.length}');
    logger.info(buffer.toString().trim());
  }
}
