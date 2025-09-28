import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:today_smart/services/google_auth_service.dart';
import 'package:today_smart/services/user_profile_service.dart';

import 'package:today_smart/features/players/players_page.dart';
import 'package:today_smart/features/fixtures/fixtures_page.dart';
import 'package:today_smart/features/standings/pages/standings_page.dart';
import 'package:today_smart/features/players/top_scorers_page.dart';
import 'package:today_smart/features/leagues/leagues_page.dart';
import 'package:today_smart/features/settings/settings_page.dart';
import 'package:today_smart/features/home/cards/cards_page.dart';
import 'package:today_smart/features/localization/export_leagues.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;

        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // غير مسجل → زر تسجيل الدخول
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("🏠 الصفحة الرئيسية")),
            body: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول بواسطة Google'),
                onPressed: () async {
                  try {
                    await GoogleAuthService.signInWithGoogle();
                    // أول مرّة: نطلب الاسم ونحفظه
                    await UserProfileService.promptForDisplayNameIfNeeded(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل تسجيل الدخول: $e')),
                    );
                  }
                },
              ),
            ),
          );
        }

        // مسجّل دخول → نقرأ الاسم من Firestore
        final uid = user.uid;
        return Scaffold(
          appBar: AppBar(
            title: StreamBuilder<String?>(
              stream: UserProfileService.displayNameStream(uid),
              builder: (context, nameSnap) {
                final name = (nameSnap.data ?? user.displayName ?? user.email ?? 'الصفحة الرئيسية').toString();
                return Text('👋 أهلاً، $name');
              },
            ),
            actions: [
              if (user.photoURL != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(user.photoURL!)),
                ),
              IconButton(
                tooltip: 'تسجيل الخروج',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await GoogleAuthService.signOut();
                },
              ),
            ],
          ),
          body: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(context, "🚀 المباريات", Icons.bolt, Colors.grey, const FixturesPage()),
              _buildCard(context, "👥 اللاعبين", Icons.person, Colors.deepPurple, const PlayersPage()),
              _buildCard(context, "📊 الترتيب", Icons.bar_chart, Colors.green, const StandingsPage()),
              _buildCard(
                context,
                "🥅 الهدافين",
                Icons.sports_soccer,
                Colors.red,
                const TopScorersPage(leagueId: 39, leagueName: "الدوري الإنجليزي"),
              ),
              _buildCard(context, "🏆 البطولات", Icons.emoji_events, Colors.purple, const LeaguesPage()),
              _buildCard(context, "⚙️ الإعدادات", Icons.settings, Colors.teal, const SettingsPage()),
              _buildCard(context, "🎴 بطاقات تشاركية", Icons.share, Colors.blue, const CardsPage()),

              // كرت التصدير المؤقت
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
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
      },
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
