// lib/features/players/services/players_repository.dart
import 'package:hive/hive.dart';
import 'package:today_smart/core/services/api_client.dart';
import 'package:today_smart/core/utils/repository_utils.dart';
import 'package:today_smart/features/leagues/services/leagues_repository.dart';
import '../models/top_scorer.dart'; // ✅ نستخدم موديل الهدافين

class PlayersRepository {
  final ApiClient apiClient;
  final LeaguesRepository leaguesRepo;

  PlayersRepository(this.apiClient) : leaguesRepo = LeaguesRepository(apiClient);

  /// ✅ جلب قائمة الهدافين لدوري معيّن
  Future<List<TopScorerModel>> getTopScorers(int leagueId) async {
    final season = await leaguesRepo.getCurrentSeason(leagueId) 
        ?? RepositoryUtils.bestSeasonForApi();

    final data = await apiClient.get("players/topscorers", params: {
      "league": leagueId,
      "season": season,
    });

    final resp = data['response'];
    if (resp is! List) return [];

    return resp
        .whereType<Map<String, dynamic>>()
        .map<TopScorerModel>((row) => TopScorerModel.fromJson(row))
        .toList();
  }

  /// ✅ جلب قائمة اللاعبين في فريق معيّن (مع كاش يومي)
  Future<List<Map<String, dynamic>>> getPlayersByTeam(int teamId, {int? leagueId}) async {
    final box = Hive.box('players_cache');
    final cacheKey = 'team_$teamId';
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    const ttlMs = 24 * 60 * 60 * 1000;

    final cached = box.get(cacheKey);
    if (cached is Map && cached['ts'] is int && cached['players'] is List) {
      final age = nowMs - (cached['ts'] as int);
      if (age < ttlMs) {
        return List<Map<String, dynamic>>.from(cached['players']);
      }
    }

    try {
      final squads = await apiClient.get("players/squads", params: {"team": teamId});
      final fromSquads = _parseSquadsSafe(squads);
      if (fromSquads.isNotEmpty) {
        await _saveCache(box, cacheKey, nowMs, fromSquads);
        return fromSquads;
      }

      int season = leagueId != null
          ? await leaguesRepo.getCurrentSeason(leagueId) ?? RepositoryUtils.bestSeasonForApi()
          : RepositoryUtils.bestSeasonForApi();

      Map<String, dynamic> data = await apiClient.get("players", params: {
        "team": teamId,
        "season": season,
      });
      var fromPlayers = _parsePlayersSafe(data);

      if (fromPlayers.isEmpty) {
        data = await apiClient.get("players", params: {
          "team": teamId,
          "season": season - 1,
        });
        fromPlayers = _parsePlayersSafe(data);
      }

      if (fromPlayers.isNotEmpty) {
        await _saveCache(box, cacheKey, nowMs, fromPlayers);
      }

      return fromPlayers;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveCache(Box box, String key, int ts, List<Map<String, dynamic>> data) async {
    await box.put(key, {'ts': ts, 'players': data});
  }

  List<Map<String, dynamic>> _parseSquadsSafe(Map<String, dynamic> data) {
    final out = <Map<String, dynamic>>[];
    final resp = data['response'];

    if (resp is List && resp.isNotEmpty) {
      final first = resp.first;
      if (first is Map) {
        final players = first['players'];
        if (players is List) {
          for (final p in players) {
            if (p is Map) {
              out.add({
                "id": RepositoryUtils.asInt(p['id']),
                "name": (p['name'] ?? "").toString(),
                "photo": (p['photo'] ?? "").toString(),
                "position": (p['position'] ?? "").toString(),
                "age": RepositoryUtils.asInt(p['age']),
                "nationality": (p['nationality'] ?? "").toString(),
              });
            }
          }
        }
      }
    }
    return out;
  }

  List<Map<String, dynamic>> _parsePlayersSafe(Map<String, dynamic> data) {
    final out = <Map<String, dynamic>>[];
    final resp = data['response'];
    if (resp is! List || resp.isEmpty) return out;

    for (final row in resp) {
      if (row is Map) {
        final player = row['player'];
        final statsList = row['statistics'];
        final playerMap = (player is Map) ? player : <String, dynamic>{};
        Map<String, dynamic> games = const {};
        if (statsList is List && statsList.isNotEmpty && statsList.first is Map) {
          final firstStats = statsList.first as Map;
          if (firstStats['games'] is Map) {
            games = Map<String, dynamic>.from(firstStats['games'] as Map);
          }
        }
        out.add({
          "id": RepositoryUtils.asInt(playerMap['id']),
          "name": (playerMap['name'] ?? "").toString(),
          "photo": (playerMap['photo'] ?? "").toString(),
          "position": (games['position'] ?? "").toString(),
          "age": RepositoryUtils.asInt(playerMap['age']),
          "nationality": (playerMap['nationality'] ?? "").toString(),
        });
      }
    }
    return out;
  }
}
