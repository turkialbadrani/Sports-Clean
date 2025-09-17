import 'package:hive/hive.dart';
import 'json_hive_helper.dart';
import 'hive_boxes.dart';

class ClubsRepository {
  static const _boxName = HiveBoxes.clubs;
  static const _jsonPath = 'assets/localization/teams_ar.json';

  Future<void> loadClubs() async {
    final box = await Hive.openBox(_boxName);
    if (box.isEmpty) {
      final data = await JsonHiveHelper.loadJson(_jsonPath);
      await box.put('all', data);
    }
  }

  List<dynamic> getClubs() {
    final box = Hive.box(_boxName);
    return box.get('all', defaultValue: []);
  }
}
