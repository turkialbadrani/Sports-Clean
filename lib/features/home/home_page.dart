import 'package:today_smart/features/players/players_page.dart';
import 'package:flutter/material.dart';
import 'package:today_smart/features/fixtures/fixtures_page.dart';
import 'package:today_smart/features/standings/pages/standings_page.dart';
import 'package:today_smart/features/players/top_scorers_page.dart';
import 'package:today_smart/features/leagues/leagues_page.dart';
import 'package:today_smart/features/settings/settings_page.dart';
import 'package:today_smart/features/home/cards/cards_page.dart';
import 'package:today_smart/features/localization/export_leagues.dart'; // ✅ استدعاء الملف

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏠 الصفحة الرئيسية")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(context, "🚀 المباريات", Icons.bolt, Colors.grey, FixturesPage()),
          _buildCard(context, "👥 اللاعبين", Icons.person, Colors.deepPurple, PlayersPage()),
          _buildCard(context, "📊 الترتيب", Icons.bar_chart, Colors.green, StandingsPage()),
          _buildCard(
            context,
            "🥅 الهدافين",
            Icons.sports_soccer,
            Colors.red,
            TopScorersPage(leagueId: 39, leagueName: "الدوري الإنجليزي"),
          ),
          _buildCard(context, "🏆 البطولات", Icons.emoji_events, Colors.purple, LeaguesPage()),
          _buildCard(context, "⚙️ الإعدادات", Icons.settings, Colors.teal, SettingsPage()),
          _buildCard(context, "🎴 بطاقات تشاركية", Icons.share, Colors.blue, CardsPage()),

          // ✅ الكرت المؤقت لتشغيل سكربت التصدير
          GestureDetector(
            onTap: () async {
              await exportLeaguesTeamsPlayers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ تم جلب الدوريات والفرق واللاعبين")),
              );
            },
            child: Card(
              color: Colors.orange.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.download, color: Colors.orange, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "📥 تصدير البيانات",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
