import 'package:flutter/foundation.dart';
import 'package:today_smart/features/players/models/player.dart';
import 'package:today_smart/features/players/services/players_repository.dart';

/// ✅ Enum لإدارة الحالة
enum LoadState { idle, loading, success, error }

class PlayersProvider with ChangeNotifier {
  final PlayersRepository _playersRepo;

  // تخزين لاعبين كل فريق
  final Map<int, List<Player>> _teamPlayers = {};

  // الحالة العامة
  LoadState teamsState = LoadState.idle;
  LoadState playersState = LoadState.idle;
  String? playersError;

  // اختيارات المستخدم
  int? selectedLeagueId;
  int? selectedTeamId;

  PlayersProvider(this._playersRepo);

  /// ✅ تعيين الدوري
  void setLeague(int? leagueId) {
    selectedLeagueId = leagueId;
    selectedTeamId = null;
    notifyListeners();
  }

  /// ✅ تعيين الفريق
  Future<void> setTeam(int? teamId) async {
    selectedTeamId = teamId;
    if (teamId != null) {
      await loadPlayersForTeam(teamId, leagueId: selectedLeagueId);
    }
    notifyListeners();
  }

  /// ✅ تحميل لاعبين فريق (مع كاش داخلي)
  Future<void> loadPlayersForTeam(int teamId, {int? leagueId}) async {
    if (_teamPlayers.containsKey(teamId)) return; // عندنا كاش

    playersState = LoadState.loading;
    playersError = null;
    notifyListeners();

    try {
      final raw = await _playersRepo.getPlayersByTeam(teamId, leagueId: leagueId);
      final players = raw.map((row) => Player.fromJson(row)).toList();
      _teamPlayers[teamId] = players;
      playersState = LoadState.success;
    } catch (e) {
      playersState = LoadState.error;
      playersError = e.toString();
    }

    notifyListeners();
  }

  /// ✅ تحديث اللاعبين للفريق الحالي
  Future<void> refreshPlayers() async {
    if (selectedTeamId != null) {
      _teamPlayers.remove(selectedTeamId); // نمسح الكاش
      await loadPlayersForTeam(selectedTeamId!, leagueId: selectedLeagueId);
    }
  }

  /// ✅ إرجاع لاعبي الفريق الحالي
  List<Player> get players {
    if (selectedTeamId == null) return [];
    return _teamPlayers[selectedTeamId!] ?? [];
  }

  /// ✅ إرجاع لاعبي أي فريق
  List<Player> getTeamPlayers(int teamId) {
    return _teamPlayers[teamId] ?? [];
  }
}
