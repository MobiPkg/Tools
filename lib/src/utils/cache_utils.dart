import 'dart:convert';

import 'package:mobipkg_tools/mobipkg_tools.dart';

abstract class CacheUtils<T> {
  final File cacheFile;

  CacheUtils(String cachePath)
      : assert(cachePath.isNotEmpty),
        cacheFile = File(cachePath);

  void save(T data) {
    final dataString = encodeData(data);
    if (!cacheFile.existsSync()) {
      cacheFile.createSync(recursive: true);
    }
    cacheFile.writeAsStringSync(dataString);

    logger.debug('Cache saved: ${cacheFile.path}');
  }

  T load() {
    if (!cacheFile.existsSync()) {
      cacheFile.createSync(recursive: true);
    }
    final dataString = cacheFile.readAsStringSync();
    try {
      return decodeData(dataString);
    } catch (e) {
      return defaultValue();
    }
  }

  T defaultValue();

  String encodeData(T data);

  T decodeData(String text);
}

class StringSetStringCache extends CacheUtils<Map<String, Set<String>>> {
  StringSetStringCache(super.cacheFile);

  @override
  Map<String, Set<String>> decodeData(String text) {
    final result = <String, Set<String>>{};

    // decode from json text
    final map = jsonDecode(text);
    if (map is Map) {
      for (final key in map.keys) {
        if (key is String) {
          final value = map[key];
          if (value is List) {
            final set = <String>{};
            for (final item in value) {
              if (item is String) {
                set.add(item);
              }
            }
            result[key] = set;
          }
        }
      }
    }

    return result;
  }

  @override
  String encodeData(Map<String, Set<String>> data) {
    final map = <String, List<String>>{};
    for (final key in data.keys) {
      final set = data[key];
      if (set != null) {
        map[key] = set.toList();
      }
    }
    return JsonEncoder.withIndent('  ').convert(map);
  }

  @override
  Map<String, Set<String>> defaultValue() {
    return {};
  }
}
