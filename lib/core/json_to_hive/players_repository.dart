import 'package:hive/hive.dart';
import 'json_hive_helper.dart';
import 'hive_boxes.dart';

class PlayersRepository {
  static const _boxName = HiveBoxes.players;
  static const _jsonPath = 'assets/localization/players_ar.json';

  Future<void> loadPlayers() async {
    final box = await Hive.openBox(_boxName);
    if (box.isEmpty) {
      final data = await JsonHiveHelper.loadJson(_jsonPath);
      await box.put('all', data);
    }
  }

  List<dynamic> getPlayers() {
    final box = Hive.box(_boxName);
    return box.get('all', defaultValue: []);
  }
}
