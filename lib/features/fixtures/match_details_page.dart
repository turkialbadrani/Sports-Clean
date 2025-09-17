import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ الموديلات
import 'models/fixture.dart';
import 'models/lineup.dart';
import 'models/event.dart';
import 'models/stats.dart';

// ✅ المستودع
import 'services/fixtures_repository.dart';

// ✅ التعريب
import 'package:today_smart/features/localization/ar_names.dart';
import 'package:today_smart/features/localization/ar_fixtures.dart';
import '../localization/ar_lineup.dart';


class MatchDetailsPage extends StatefulWidget {
  final FixtureModel fixture;

  const MatchDetailsPage({super.key, required this.fixture});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // ✅ 4 تبويبات
  }

  @override
  Widget build(BuildContext context) {
    final home = widget.fixture.home;
    final away = widget.fixture.away;
    final goals = widget.fixture.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل المباراة"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "📝 الملخص"),
            Tab(text: "👥 التشكيلة"),
            Tab(text: "📒 الأحداث"),
            Tab(text: "📊 الإحصائيات"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(
            home.logoUrl, teamArByIdWithFallback(home.id, home.name), goals.home,
            away.logoUrl, teamArByIdWithFallback(away.id, away.name), goals.away,
          ),
          _buildLineupTab(),
          _buildEventsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  // 📝 ملخص المباراة
  Widget _buildSummaryTab(
      String? homeLogo, String homeName, int? homeGoals,
      String? awayLogo, String awayName, int? awayGoals) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _teamColumn(homeLogo, homeName, homeGoals),
              const Text("VS", style: TextStyle(fontSize: 20)),
              _teamColumn(awayLogo, awayName, awayGoals),
            ],
          ),
          const SizedBox(height: 20),
          Text("📅 ${widget.fixture.date.toLocal()}",
              style: const TextStyle(fontSize: 14)),
          Text("⏱️ ${widget.fixture.status.toArabic()}",
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // 👥 التشكيلة
  Widget _buildLineupTab() {
    return FutureBuilder(
      future: context.read<FixturesRepository>().getLineups(widget.fixture.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("❌ خطأ: ${snapshot.error}"));
        }
        final lineups = snapshot.data as List<Lineup>;
        if (lineups.isEmpty) {
          return const Center(child: Text("لا توجد تشكيلات متوفرة"));
        }
        return ListView.builder(
          itemCount: lineups.length,
          itemBuilder: (context, index) {
            final lineup = lineups[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ExpansionTile(
                leading: lineup.teamLogo != null
                    ? Image.network(lineup.teamLogo!, height: 30)
                    : const Icon(Icons.sports_soccer),
                title: Text(
                  teamArByIdWithFallback(lineup.teamId, lineup.teamName),
                ),
                children: lineup.startXI.map((p) {
                  return ListTile(
                    title: Text(
                      playerArByIdWithFallback(p.id, p.name),
                    ),
                    subtitle: Text("المركز: ${lineupPositionAr(p.pos)}"),

                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  // 📒 الأحداث
  Widget _buildEventsTab() {
    return FutureBuilder(
      future: context.read<FixturesRepository>().getEvents(widget.fixture.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("❌ خطأ: ${snapshot.error}"));
        }
        final events = snapshot.data as List<FixtureEvent>;
        if (events.isEmpty) {
          return const Center(child: Text("لا توجد أحداث متوفرة"));
        }
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            return ListTile(
              leading: Text("⏱️ ${e.minute}'"),
              title: Text(eventTypeAr(e.type, e.detail)), // ✅ تعريب نوع الحدث
              subtitle: Text(
                "${playerArByIdWithFallback(e.playerId ?? 0, e.playerName ?? '')} "
                "(${teamArByIdWithFallback(e.teamId ?? 0, e.teamName)})",
              ),
            );
          },
        );
      },
    );
  }
 // 📊 الإحصائيات
Widget _buildStatsTab() {
  return FutureBuilder(
    future: context.read<FixturesRepository>().getStatistics(widget.fixture.id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text("❌ خطأ: ${snapshot.error}"));
      }
      final stats = snapshot.data as List<FixtureStatistics>;
      if (stats.isEmpty) {
        return const Center(child: Text("لا توجد إحصائيات متوفرة"));
      }
      return ListView.builder(
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final teamStats = stats[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ExpansionTile(
              leading: teamStats.teamLogo != null
                  ? Image.network(teamStats.teamLogo!, height: 30)
                  : const Icon(Icons.sports_soccer),
              title: Text(
                teamArByIdWithFallback(teamStats.teamId ?? 0, teamStats.teamName),
              ),
              children: teamStats.stats.map((s) {
                return ListTile(
                  title: Text(statTypeAr(s.type)), // ✅ تعريب الإحصائية
                  trailing: Text(s.value),
                );
              }).toList(),
            ),
          );
        },
      );
    },
  );
}


  Widget _teamColumn(String? logo, String name, int? goals) {
    return Column(
      children: [
        if (logo != null)
          Image.network(logo, height: 50)
        else
          const Icon(Icons.shield, size: 50),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          goals?.toString() ?? "-",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
