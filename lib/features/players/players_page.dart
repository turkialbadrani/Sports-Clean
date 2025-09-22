import 'package:today_smart/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/settings/settings_provider.dart';
import '../../core/json_to_hive/leagues_repository.dart';
import '../../core/services/leagues_service.dart';
import '../../core/services/api_client.dart';

// 🟢 استدعاء التعريب
import 'package:today_smart/features/localization/ar_names.dart';
import 'package:today_smart/features/localization/localization_ar.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  late final LeaguesRepository leaguesRepo;
  late final LeaguesService leaguesService;

  int? selectedLeagueId;
  int? selectedClubId;

  List<dynamic> allLeagues = [];
  List<dynamic> clubs = [];
  List<Map<String, dynamic>> players = [];

  bool isLoadingLeagues = false;
  bool isLoadingClubs = false;
  bool isLoadingPlayers = false;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient(
      apiKey: AppConfig.apiKey,
      timezone: AppConfig.timezone!,
      leagues: [],
    );

    leaguesRepo = LeaguesRepository();
    leaguesService = LeaguesService(apiClient: apiClient);

    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    setState(() => isLoadingLeagues = true);
    await leaguesRepo.loadLeagues();
    setState(() {
      allLeagues = leaguesRepo.getLeagues();
      isLoadingLeagues = false;
    });
  }

  Future<void> _loadClubsFromApi(int leagueId) async {
    setState(() => isLoadingClubs = true);
    final result = await leaguesService.getClubsByLeague(leagueId);
    setState(() {
      clubs = result;
      selectedClubId = null;
      players = [];
      isLoadingClubs = false;
    });
  }

  Future<void> _loadPlayersFromApi(int teamId, int leagueId) async {
    setState(() => isLoadingPlayers = true);
    final result = await leaguesService.getPlayersByClub(teamId, leagueId: leagueId);
    setState(() {
      players = result;
      isLoadingPlayers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final favoriteLeagueIds = settingsProvider.preferredLeagues;

    final favoriteLeagues = allLeagues
        .where((l) => favoriteLeagueIds.contains(l['id']))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("اللاعبين")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🟢 الدوريات
            if (isLoadingLeagues)
              const Center(child: CircularProgressIndicator())
            else if (favoriteLeagues.isNotEmpty)
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text("اختر دوري"),
                value: selectedLeagueId,
                items: favoriteLeagues.map<DropdownMenuItem<int>>((league) {
                  final localizedLeagueName = arName(
                    kind: ArNameKind.league,
                    id: league['id'],
                    name: league['name'],
                  );
                  return DropdownMenuItem(
                    value: league['id'],
                    child: Text(localizedLeagueName),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    setState(() => selectedLeagueId = id);
                    _loadClubsFromApi(id);
                  }
                },
              ),

            const SizedBox(height: 16),

            // 🟢 الأندية
            if (isLoadingClubs)
              const Center(child: CircularProgressIndicator())
            else if (selectedLeagueId != null)
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text("اختر نادي"),
                value: selectedClubId,
                items: clubs.map<DropdownMenuItem<int>>((club) {
                  final team = club['team'] ?? {};
                  final localizedTeamName = arName(
                    kind: ArNameKind.team,
                    id: team['id'],
                    name: team['name'],
                  );
                  return DropdownMenuItem(
                    value: team['id'],
                    child: Row(
                      children: [
                        if (team['logo'] != null)
                          Image.network(team['logo'], width: 24, height: 24),
                        const SizedBox(width: 8),
                        Text(localizedTeamName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    setState(() => selectedClubId = id);
                    _loadPlayersFromApi(id, selectedLeagueId!);
                  }
                },
              ),

            const SizedBox(height: 16),

            // 🟢 اللاعبين
            if (isLoadingPlayers)
              const Center(child: CircularProgressIndicator())
            else if (selectedClubId != null)
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final localizedPlayerName = arName(
                      kind: ArNameKind.player,
                      id: player['id'],
                      name: player['name'],
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(player['photo']),
                      ),
                      title: Text(localizedPlayerName),
                      subtitle: Text(
                        "${player['position']} • ${player['nationality']}",
                      ),
                      trailing: Text(player['age']?.toString() ?? ""),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
