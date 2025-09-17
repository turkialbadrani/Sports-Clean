import 'package:today_smart/features/localization/localization_ar.dart';

class TopScorerModel {
  final int playerId;
  final String playerName;
  final int goals;
  final String? photoUrl;

  TopScorerModel({
    required this.playerId,
    required this.playerName,
    required this.goals,
    this.photoUrl,
  });

  factory TopScorerModel.fromJson(Map<String, dynamic> json) {
    final player = json['player'] ?? {};
    final id = player['id'] as int? ?? 0;
    final fallbackName = player['name'] as String? ?? "";

    return TopScorerModel(
      playerId: id,
      playerName: LocalizationAr.playerName(id, fallbackName),
      goals: (json['statistics']?[0]?['goals']?['total'] ?? 0) as int,
      photoUrl: player['photo'] as String?,
    );
  }
}
