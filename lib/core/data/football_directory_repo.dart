// lib/core/data/football_directory_repo.dart
import 'package:hive/hive.dart';
import '../../features/localization/localization_ar.dart';
import '../../features/leagues/services/leagues_repository.dart';
import '../../features/players/services/players_repository.dart';
import 'models.dart';
import 'mappers.dart';

/// Facade موحّد مبني على LeaguesRepository و PlayersRepository
class FootballDirectory {
  final LeaguesRepository leaguesRepo;
  final PlayersRepository playersRepo;
  final List<int> allowedLeagues;
  FootballDirectory({required this.leaguesRepo, required this.playersRepo, required this.allowedLeagues});

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

    // نركّب الدوريات من اللائحة المسموح بها + التعريب كاسم افتراضي
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

    final raw = await leaguesRepo.getTeamsByLeague(leagueId);
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

    final raw = await playersRepo.getPlayersByTeam(teamId);
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
