// lib/core/data/football_directory.dart
import 'package:hive/hive.dart';
import '../../features/localization/localization_ar.dart'; // optional for eager localization if desired
import '../services/api_client.dart' as core_api; // adjust import path if needed
import 'models.dart';
import 'mappers.dart';

/// Facade توحّد جلب الدوريات/الفرق/اللاعبين مع كاش بسيط عبر Hive.
class FootballDirectory {
  final core_api.ApiClient api;
  final List<int> allowedLeagues;
  FootballDirectory({required this.api, required this.allowedLeagues});

  // صناديق كاش اختيارية (أسماء افتراضية)
  final String leaguesBoxName = 'fd_leagues_cache';
  final String teamsBoxName   = 'fd_teams_cache';
  final String playersBoxName = 'fd_players_cache';

  Future<List<LeagueRef>> getLeagues({bool useCache = true, Duration ttl = const Duration(hours: 12)}) async {
    final box = await _openBox(leaguesBoxName);
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheKey = 'allowed_${allowedLeagues.join(',')}';
    if (useCache && box.containsKey(cacheKey)) {
      final entry = Map<String, dynamic>.from(box.get(cacheKey));
      final ts = entry['ts'] as int? ?? 0;
      if (now - ts < ttl.inMilliseconds) {
        final list = (entry['data'] as List).map((e) => LeagueRef(
          id: e['id'] as int,
          name: e['name'] as String,
          logo: e['logo'] as String?,
        )).toList();
        return list;
      }
    }

    // NOTE: api should have an endpoint to get meta leagues. If not, we can synthesize from allowedLeagues.
    // Here we synthesize basic LeagueRef using localization for names.
    final leagues = allowedLeagues.map((id) => LeagueRef(
      id: id,
      name: LocalizationAr.leagueName(id) ?? 'League $id',
      logo: null,
    )).toList();

    await box.put(cacheKey, {
      'ts': now,
      'data': leagues.map((l) => {'id': l.id, 'name': l.name, 'logo': l.logo}).toList(),
    });
    return leagues;
  }

  Future<List<TeamRef>> getTeams(int leagueId, {bool useCache = true, Duration ttl = const Duration(hours: 12)}) async {
    final box = await _openBox(teamsBoxName);
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheKey = 'league_$leagueId';
    if (useCache && box.containsKey(cacheKey)) {
      final entry = Map<String, dynamic>.from(box.get(cacheKey));
      final ts = entry['ts'] as int? ?? 0;
      if (now - ts < ttl.inMilliseconds) {
        final list = (entry['data'] as List).map((e) => TeamRef(
          id: e['id'] as int, name: e['name'] as String, logo: e['logo'] as String?,
        )).toList();
        return list;
      }
    }

    final raw = await api.getTeamsByLeague(leagueId); // assumes you expose this on ApiClient or via repo
    final teams = <TeamRef>[];
    for (final r in raw) {
      final t = mapTeam(r);
      if (t != null) teams.add(t);
    }

    await box.put(cacheKey, {
      'ts': now,
      'data': teams.map((t) => {'id': t.id, 'name': t.name, 'logo': t.logo}).toList(),
    });
    return teams;
  }

  Future<List<PlayerRef>> getPlayers(int teamId, {bool useCache = true, Duration ttl = const Duration(hours: 24)}) async {
    final box = await _openBox(playersBoxName);
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheKey = 'team_$teamId';
    if (useCache && box.containsKey(cacheKey)) {
      final entry = Map<String, dynamic>.from(box.get(cacheKey));
      final ts = entry['ts'] as int? ?? 0;
      if (now - ts < ttl.inMilliseconds) {
        final list = (entry['data'] as List).map((e) => PlayerRef(
          id: e['id'] as int,
          name: e['name'] as String,
          photo: e['photo'] as String?,
          position: e['position'] as String?,
        )).toList();
        return list;
      }
    }

    final raw = await api.getPlayersByTeam(teamId); // assumes endpoint on ApiClient
    final players = <PlayerRef>[];
    for (final r in raw) {
      final p = mapPlayer(r);
      if (p != null) players.add(p);
    }

    await box.put(cacheKey, {
      'ts': now,
      'data': players.map((p) => {
        'id': p.id, 'name': p.name, 'photo': p.photo, 'position': p.position,
      }).toList(),
    });
    return players;
  }

  Future<Box> _openBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box(name);
    return await Hive.openBox(name);
  }
}