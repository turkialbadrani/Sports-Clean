import 'package:today_smart/core/services/api_client.dart';
import 'package:today_smart/core/utils/repository_utils.dart';
import 'package:flutter/foundation.dart';

class LeaguesService {
  final ApiClient apiClient;

  LeaguesService({required this.apiClient});

  /// 🟢 جلب قائمة الدوريات
  Future<List<Map<String, dynamic>>> getLeagues() async {
    try {
      final response = await apiClient.get("leagues");
      return List<Map<String, dynamic>>.from(response['response']);
    } catch (e) {
      throw Exception("Error fetching leagues: $e");
    }
  }

  /// 🟢 جلب الأندية الخاصة بدوري معيّن (مع الموسم)
  Future<List<Map<String, dynamic>>> getClubsByLeague(int leagueId) async {
    try {
      final season = RepositoryUtils.bestSeasonForApi();

      final response = await apiClient.get(
        "teams",
        params: {
          "league": leagueId.toString(),
          "season": season.toString(),
        },
      );

      final resp = response['response'];
      if (resp is! List) return [];

      debugPrint("📌 getClubsByLeague($leagueId, season=$season) → ${resp.length} clubs");

      return resp.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception("Error fetching clubs for league $leagueId: $e");
    }
  }

  /// 🟢 جلب لاعبي نادي معيّن (مع الموسم)
  Future<List<Map<String, dynamic>>> getPlayersByClub(
    int teamId, {
    int? leagueId,
    int? season,
  }) async {
    try {
      final usedSeason = season ?? RepositoryUtils.bestSeasonForApi();

      final response = await apiClient.get(
        "players",
        params: {
          "team": teamId.toString(),
          if (leagueId != null) "league": leagueId.toString(),
          "season": usedSeason.toString(),
        },
      );

      final resp = response['response'];
      if (resp is! List) return [];

      final out = <Map<String, dynamic>>[];
      for (final row in resp) {
        if (row is Map) {
          final player = row['player'];
          if (player is Map) {
            out.add({
              "id": RepositoryUtils.asInt(player['id']),
              "name": (player['name'] ?? "").toString(),
              "photo": (player['photo'] ?? "").toString(),
              "age": RepositoryUtils.asInt(player['age']),
              "nationality": (player['nationality'] ?? "").toString(),
              "position": (row['statistics'] is List &&
                      row['statistics'].isNotEmpty)
                  ? (row['statistics'][0]['games']?['position'] ?? "").toString()
                  : "",
            });
          }
        }
      }

      debugPrint("📌 getPlayersByClub($teamId, season=$usedSeason) → ${out.length} players");

      return out;
    } catch (e) {
      throw Exception("Error fetching players for club $teamId: $e");
    }
  }
}
