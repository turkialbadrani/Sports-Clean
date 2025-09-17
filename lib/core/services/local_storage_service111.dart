import 'package:hive/hive.dart';
import 'package:today_smart/features/players/models/top_scorer.dart';

class LocalStorageService {
  final Box box = Hive.box('top_scorers');

  Future<void> saveTopScorers(List<TopScorerModel> scorers) async {
    final data = scorers.map((s) => {
      'player': {
        'id': s.playerId,
        'name': s.playerName,
        'photo': s.photoUrl,
      },
      'statistics': [
        {'goals': {'total': s.goals}}
      ]
    }).toList();
    await box.put('scorers', data);
  }

  List<TopScorerModel> getTopScorers() {
    final data = box.get('scorers', defaultValue: []) as List;
    return data.map((item) => TopScorerModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }
}
