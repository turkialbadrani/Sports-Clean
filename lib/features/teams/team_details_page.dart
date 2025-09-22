import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:today_smart/features/players/providers/players_provider.dart';
import 'package:today_smart/features/fixtures/providers/fixtures_provider.dart';
import 'package:today_smart/features/localization/ar_names.dart';
import 'package:today_smart/features/localization/localization_ar.dart';
import 'package:today_smart/features/players/models/player.dart';
import 'package:today_smart/features/fixtures/models/fixture.dart';

class TeamDetailsPage extends StatelessWidget {
  final int teamId;
  final String teamName;

  const TeamDetailsPage({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    final playersProvider = context.watch<PlayersProvider>();
    final fixturesProvider = context.watch<FixturesProvider>();

    // ✅ تعريب اسم الفريق
    final localizedName = arName(
      kind: ArNameKind.team,
      id: teamId,
      name: LocalizationAr.teamName(teamId, teamName),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedName),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "👥 اللاعبون"),
                Tab(text: "⚽ المباريات"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ✅ تبويب اللاعبين
                  _buildPlayersTab(playersProvider),

                  // ✅ تبويب المباريات
                  _buildFixturesTab(fixturesProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersTab(PlayersProvider provider) {
    final squad = provider.getTeamPlayers(teamId);

    if (squad.isEmpty) {
      return const Center(child: Text("لا توجد بيانات لاعبين"));
    }

    return ListView.builder(
      itemCount: squad.length,
      itemBuilder: (context, index) {
        final Player player = squad[index];
        final playerName = arName(
          kind: ArNameKind.player,
          id: player.id,
          name: player.name,
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: player.photo.isNotEmpty
                ? NetworkImage(player.photo)
                : null,
            child: player.photo.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(playerName),
          subtitle: Text("المركز: ${player.position?.toString() ?? 'غير معروف'}"),
        );
      },
    );
  }

  Widget _buildFixturesTab(FixturesProvider provider) {
    final List<FixtureModel> matches = provider.getTeamFixtures(teamId);

    if (matches.isEmpty) {
      return const Center(child: Text("لا توجد مباريات لهذا الفريق"));
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final home = arName(
          kind: ArNameKind.team,
          id: match.home.id,
          name: match.home.name,
        );
        final away = arName(
          kind: ArNameKind.team,
          id: match.away.id,
          name: match.away.name,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text("$home vs $away"),
            subtitle: Text("🗓️ ${match.date ?? '---'}"),
            trailing: Text(match.status?.toString() ?? ""),
          ),
        );
      },
    );
  }
}
