import 'package:hive/hive.dart';
import 'json_hive_helper.dart';
import 'hive_boxes.dart';

class LeaguesRepository {
  static const _boxName = HiveBoxes.leagues;
  static const _jsonPath = 'assets/localization/leagues_ar.json';

  Future<void> loadLeagues() async {
    final box = await Hive.openBox(_boxName);
    if (box.isEmpty) {
      final data = await JsonHiveHelper.loadJson(_jsonPath);
      await box.put('all', data);
    }
  }

  List<dynamic> getLeagues() {
    final box = Hive.box(_boxName);
    return box.get('all', defaultValue: []);
  }
}
