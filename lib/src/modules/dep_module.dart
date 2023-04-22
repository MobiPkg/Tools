import 'dart:convert';

import 'package:mobipkg_tools/mobipkg_tools.dart';
import 'package:path/path.dart';

class Dep {
  final String name;
  final List<Dep> firstLevelDeps;
  final List<Dep> deps;

  Dep(this.name, this.firstLevelDeps, this.deps);

  String treeString({
    int level = 0,
    Set<String>? alreadyPrinted,
  }) {
    if (alreadyPrinted != null) {
      if (alreadyPrinted.contains(name)) {
        return '${'  ' * level}$name...\n';
      }
      alreadyPrinted.add(name);
    }

    final sb = StringBuffer();
    sb.write('  ' * level);
    sb.write(name);
    sb.write('\n');
    for (final dep in firstLevelDeps) {
      sb.write(dep.treeString(
        level: level + 1,
        alreadyPrinted: alreadyPrinted,
      ));
    }
    return sb.toString();
  }

  Map toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['firstLevelDeps'] = firstLevelDeps.map((e) => e.name).toList();
    map['deps'] = deps.map((e) => e.toJson()).toList();
    return map;
  }

  static List<Dep> findEmptyDependenciesInCache() {
    final files = Directory(_cachePath).listSync();

    final emptyDeps = <Dep>[];

    for (final file in files) {
      if (!file.path.endsWith('.json')) {
        continue;
      }
      final name = basenameWithoutExtension(file.path);

      if (!name.startsWith('dep_')) {
        continue;
      }

      final depName = name.substring(4);
      final cache = StringSetStringCache(file.path);

      final deps = cache.load()[depName];
      if (deps == null) {
        continue;
      }

      if (deps.isEmpty) {
        emptyDeps.add(Dep(depName, [], []));
      }
    }

    return emptyDeps;
  }
}

class DepFinder {
  DepFinder(this.package);

  final String package;

  Set<Dep> find() {
    return _DepFinder.withPlatform(package).find();
  }
}

abstract class _DepFinder {
  _DepFinder(this.package);

  factory _DepFinder.withPlatform(String package) {
    return _MacDepFinder(package);
  }

  final String package;

  Set<Dep> find();
}

final _cachePath = '${Platform.environment['HOME']}/.cache/.mobipkg_tools';

class _MacDepFinder extends _DepFinder {
  _MacDepFinder(String package) : super(package);

  final _depSet = <String>{};

  StringSetStringCache getCacheWithDep(String pkgName) {
    return StringSetStringCache('$_cachePath/dep_$pkgName.json');
  }

  void addAllDep(Set<String> deps) {
    for (final dep in deps) {
      if (_depSet.contains(dep)) {
        continue;
      }
      _depSet.add(dep);
      logger.debug('Adding $dep');

      final firstLevelDeps = getFirstLevelDependencies(dep);
      addAllDep(firstLevelDeps);
    }
    _depSet.addAll(deps);
  }

  @override
  Set<Dep> find() {
    _depSet.clear();

    final firstLevelDeps = getFirstLevelDependencies(package);
    addAllDep(firstLevelDeps);

    final result = <Dep>{};

    for (final dep in _depSet) {
      result.add(createDep(dep));
    }

    return result;
  }

  Dep createDep(String name) {
    // recursive
    final firstLevelDeps = getFirstLevelDependencies(name);
    final deps = <Dep>{};
    for (final dep in firstLevelDeps) {
      deps.add(createDep(dep));
    }

    return Dep(
      name,
      deps.where((element) => firstLevelDeps.contains(element.name)).toList(),
      deps.toList(),
    );
  }

  Set<String> getFirstLevelDependencies(String packageName) {
    final cache = getCacheWithDep(packageName);
    final cached = cache.load()[packageName];
    if (cached != null) {
      return cached;
    }

    final cmd = 'brew info --json $packageName';
    final text = shell.runSync(cmd);
    final list = jsonDecode(text) as List;
    final map = list.first as Map;
    final deps = map['dependencies'] as List;
    final set = deps.cast<String>().toSet();

    cache.save({packageName: set});

    return set;
  }
}
