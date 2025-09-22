import 'package:today_smart/config/app_config.dart';
// lib/features/players/top_scorers_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:today_smart/core/services/api_client.dart';
import 'package:today_smart/features/localization/ar_names.dart'; 
import 'package:today_smart/features/settings/settings_provider.dart';
import 'package:today_smart/features/players/services/players_repository.dart';
import 'package:today_smart/features/players/models/top_scorer.dart';
import 'package:today_smart/features/localization/localization_ar.dart';

class TopScorersPage extends StatefulWidget {
  final int? leagueId;
  final String? leagueName;

  const TopScorersPage({super.key, this.leagueId, this.leagueName});

  @override
  State<TopScorersPage> createState() => _TopScorersPageState();
}

class _TopScorersPageState extends State<TopScorersPage> {
  late int _selectedLeague;
  late Future<List<int>> _futureLeagues;
  Future<List<TopScorerModel>>? _futureScorers;

  PlayersRepository _buildRepo(List<int> leagues) {
    return PlayersRepository(
      ApiClient(
        apiKey: AppConfig.apiKey,
        timezone: "Asia/Riyadh",
        leagues: leagues, // ✅ صار مطلوب
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final leagues = context.read<SettingsProvider>().preferredLeagues;
    final saved = Hive.box('user_prefs').get('last_scorers_league') as int?;
    final chosen = (saved != null && leagues.contains(saved))
        ? saved
        : (leagues.isNotEmpty ? leagues.first : -1);

    _futureLeagues = Future.value(leagues);
    _selectedLeague = widget.leagueId ?? chosen;

    if (_selectedLeague != -1) {
      _futureScorers = _buildRepo(leagues).getTopScorers(_selectedLeague);
    }
  }

  void _load(int leagueId) {
    setState(() {
      _selectedLeague = leagueId;
      Hive.box('user_prefs').put('last_scorers_league', leagueId);
      final leagues = context.read<SettingsProvider>().preferredLeagues;
      _futureScorers = _buildRepo(leagues).getTopScorers(leagueId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName ?? "🥅 قائمة الهدافين"),
      ),
      body: FutureBuilder<List<int>>(
        future: _futureLeagues,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final leagues = snapshot.data!;
          if (_selectedLeague == -1 && leagues.isNotEmpty) {
            _selectedLeague = leagues.first;
            _futureScorers = _buildRepo(leagues).getTopScorers(_selectedLeague);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Text("الدوري:"),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: leagues.contains(_selectedLeague)
                            ? _selectedLeague
                            : null,
                        items: leagues.map((id) {
                          final name = arName(
                            kind: ArNameKind.league,
                            id: id,
                            name: LocalizationAr.leagueName(id),
                          );
                          return DropdownMenuItem(
                            value: id,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) _load(id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _futureScorers == null
                    ? const Center(child: Text("اختر دوري لعرض الهدافين"))
                    : FutureBuilder<List<TopScorerModel>>(
                        future: _futureScorers,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("خطأ: ${snapshot.error}"));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("لا توجد بيانات"));
                          }

                          final scorers = snapshot.data!;
                          return ListView.separated(
                            itemCount: scorers.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final scorer = scorers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: scorer.photoUrl != null &&
                                          scorer.photoUrl!.isNotEmpty
                                      ? NetworkImage(scorer.photoUrl!)
                                      : null,
                                  child: (scorer.photoUrl == null ||
                                          scorer.photoUrl!.isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(arName(
                                  kind: ArNameKind.player,
                                  id: scorer.playerId,
                                  name: scorer.playerName ?? "لاعب",
                                )),
                                trailing: Text("أهداف: ${scorer.goals}"),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
