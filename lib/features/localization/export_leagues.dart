import 'package:today_smart/config/app_config.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:today_smart/features/fixtures/data/fixtures_api.dart';
import 'package:today_smart/features/settings/settings_provider.dart';
import 'package:today_smart/features/localization/ar_names.dart';

/// 📝 سكربت يساعدك تطلع فقط الدوريات + الفرق + اللاعبين لهذا الموسم
Future<void> exportLeaguesTeamsPlayers() async {
  final api = FixturesApi(apiKey: AppConfig.apiKey);
  final currentSeason = DateTime.now().year;

  // ✅ نقرأ الدوريات من JSON
  List<int> preferredLeagues = (Hive.box('user_prefs').get('preferred_leagues') as List?)?.cast<int>() ?? <int>[];
  if (preferredLeagues.isEmpty) {
    final raw = await rootBundle.loadString('assets/localization/preferred_leagues.json');
    final List<dynamic> data = jsonDecode(raw);
    preferredLeagues = data.map((e) => e as int).toList();
  }

  for (final leagueId in preferredLeagues) {
    try {
      print("🔵 جاري جلب الدوري $leagueId ...");

      // 1️⃣ جلب معلومات الدوري
      final leagueResp = await api.get("leagues", params: {
        "id": leagueId.toString(),
        "season": currentSeason.toString(),
      });

      final leaguesList = leagueResp['response'] as List<dynamic>? ?? [];
      if (leaguesList.isEmpty) continue;

      final league = leaguesList[0]['league'];
      final leagueName = league?['name'] ?? '??';

      // ✅ اطبع الدوري (لو ما له تعريب)
      leagueArByIdWithFallback(leagueId, leagueName);

      await Future.delayed(const Duration(milliseconds: 200));

      // 2️⃣ جلب كل الفرق في هذا الدوري (الموسم الحالي فقط)
      final teamsResp = await api.get("teams", params: {
        "league": leagueId.toString(),
        "season": currentSeason.toString(),
      });

      final teams = teamsResp['response'] as List<dynamic>? ?? [];
      for (final t in teams) {
        final team = t['team'] as Map<String, dynamic>? ?? {};
        final teamId = team['id'];
        final teamName = team['name'];

        if (teamId != null) {
          teamArByIdWithFallback(teamId, teamName?.toString() ?? '');
        }

        await Future.delayed(const Duration(milliseconds: 200));

        try {
          // 3️⃣ جلب اللاعبين لكل فريق (الموسم الحالي فقط)
          final playersResp = await api.get("players", params: {
            "team": teamId.toString(),
            "season": currentSeason.toString(),
          });

          final players = playersResp['response'] as List<dynamic>? ?? [];
          for (final p in players) {
            final player = p['player'] as Map<String, dynamic>? ?? {};
            final playerId = player['id'];
            final playerName = player['name'];

            if (playerId != null) {
              playerArByIdWithFallback(playerId, playerName?.toString() ?? '');
            }
          }
        } catch (_) {
          continue; // تخطي أي خطأ بالشبكة بدون طباعة
        }
      }
    } catch (_) {
      continue; // تخطي أي خطأ بالدوري بدون طباعة
    }
  }
}
