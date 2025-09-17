
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryProvider with ChangeNotifier {
  static const _boxName = 'user_prefs';
  static const _keyPath = 'data_dir';

  String? _path;
  String? get path => _path;

  Future<void> init() async {
    final box = Hive.box(_boxName);

    final stored = box.get(_keyPath);
    if (stored is String && stored.isNotEmpty) {
      _path = stored;
      return;
    }

    // نستخدم مسار التطبيق الافتراضي
    final dir = await getApplicationDocumentsDirectory();
    _path = dir.path;
    await box.put(_keyPath, _path);
  }

  Future<void> setPath(String newPath) async {
    if (newPath.isEmpty) return;
    _path = newPath;
    final box = Hive.box(_boxName);
    await box.put(_keyPath, _path);
  }
}
