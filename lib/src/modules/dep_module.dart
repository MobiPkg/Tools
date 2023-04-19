import 'dart:convert';

import 'package:mobipkg_tools/mobipkg_tools.dart';

class DepFinder {
  DepFinder(this.package);

  final String package;

  Set<String> find() {
    return _DepFinder.withPlatform(package).find();
  }
}

abstract class _DepFinder {
  _DepFinder(this.package);

  factory _DepFinder.withPlatform(String package) {
    return _MacDepFinder(package);
  }

  final String package;

  Set<String> find();
}

final _cachePath = '${Platform.environment['HOME']}/.cache/.mobipkg_tools';

class _MacDepFinder extends _DepFinder {
  _MacDepFinder(String package) : super(package);

  final _depSet = <String>{};

  final _depMap = <String, Set<String>>{};

  late final cache = StringSetStringCache('$_cachePath/dep_$package.json');

  void addAllDep(Set<String> deps) {
    for (final dep in deps) {
      if (_depSet.contains(dep)) {
        continue;
      }
      _depSet.add(dep);
      logger.info('Adding $dep');

      final firstLevelDeps = getFirstLevelDependencies(dep);
      addAllDep(firstLevelDeps);
    }
    _depSet.addAll(deps);
  }

  @override
  Set<String> find() {
    _depSet.clear();
    _depMap.clear();
    _depMap.addAll(cache.load());

    final firstLevelDeps = getFirstLevelDependencies(package);
    addAllDep(firstLevelDeps);

    return _depSet;
  }

  Set<String> getFirstLevelDependencies(String packageName) {
    final cached = _depMap[packageName];
    if (cached != null) {
      return cached;
    }

    final cmd = 'brew info --json $packageName';
    final text = shell.runSync(cmd);
    final list = jsonDecode(text) as List;
    final map = list.first as Map;
    final deps = map['dependencies'] as List;
    final set = deps.cast<String>().toSet();

    _depMap[packageName] = set;
    cache.save(_depMap);

    return set;
  }
}
