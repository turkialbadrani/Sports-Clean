// lib/features/shared/providers/directory_provider.dart
import 'package:flutter/foundation.dart';
import '../../../core/data/football_directory_repo.dart';
import '../../../core/data/models.dart';

enum LoadState { idle, loading, success, error }

class DirectoryProvider with ChangeNotifier {
  final FootballDirectory dir;
  DirectoryProvider(this.dir);

  LoadState leaguesState = LoadState.idle;
  LoadState teamsState   = LoadState.idle;
  LoadState playersState = LoadState.idle;

  String? leaguesError;
  String? teamsError;
  String? playersError;

  List<LeagueRef> leagues = const [];
  List<TeamRef> teams = const [];
  List<PlayerRef> players = const [];

  int? selectedLeagueId;
  int? selectedTeamId;

  Future<void> init({int? leagueId, int? teamId}) async {
    await loadLeagues();
    if (leagueId != null) {
      await setLeague(leagueId);
      if (teamId != null) {
        await setTeam(teamId);
      }
    }
  }

  Future<void> loadLeagues() async {
    leaguesState = LoadState.loading;
    leaguesError = null;
    notifyListeners();
    try {
      leagues = await dir.getLeagues();
      leaguesState = LoadState.success;
      notifyListeners();
    } catch (e) {
      leaguesState = LoadState.error;
      leaguesError = e.toString();
      notifyListeners();
    }
  }

  Future<void> setLeague(int leagueId) async {
    selectedLeagueId = leagueId;
    players = const [];
    playersState = LoadState.idle;
    playersError = null;
    await loadTeams(leagueId);
  }

  Future<void> loadTeams(int leagueId) async {
    teamsState = LoadState.loading;
    teamsError = null;
    notifyListeners();
    try {
      teams = await dir.getTeams(leagueId);
      teamsState = LoadState.success;
      if (teams.isNotEmpty) {
        selectedTeamId = teams.first.id;
        notifyListeners();
        await loadPlayers(selectedTeamId!);
      } else {
        selectedTeamId = null;
        players = const [];
        playersState = LoadState.idle;
        playersError = null;
        notifyListeners();
      }
    } catch (e) {
      teamsState = LoadState.error;
      teamsError = e.toString();
      notifyListeners();
    }
  }

  Future<void> setTeam(int teamId) async {
    selectedTeamId = teamId;
    await loadPlayers(teamId);
  }

  Future<void> loadPlayers(int teamId) async {
    playersState = LoadState.loading;
    playersError = null;
    notifyListeners();
    try {
      players = await dir.getPlayers(teamId);
      playersState = LoadState.success;
      notifyListeners();
    } catch (e) {
      playersState = LoadState.error;
      playersError = e.toString();
      notifyListeners();
    }
  }
}
