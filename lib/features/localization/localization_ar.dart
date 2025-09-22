import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocalizationAr {
  static Map<String, dynamic>? _leagues;
  static Map<String, dynamic>? _teams;
  static Map<String, dynamic>? _players;
  static bool _loaded = false;

  /// 🟢 تحميل كل الملفات مرة واحدة فقط
  static Future<void> load() async {
    if (_loaded) return;

    // ⚽ الدوريات
    final leaguesData = await rootBundle.loadString(
      'assets/localization/leagues_ar.json',
    );
    _leagues = jsonDecode(leaguesData) as Map<String, dynamic>;

    // 🏟️ الفرق
    try {
      final teamsData = await rootBundle.loadString(
        'assets/localization/teams_ar.json',
      );
      _teams = jsonDecode(teamsData) as Map<String, dynamic>;
    } catch (_) {
      _teams = {};
    }

    // 👤 اللاعبين
    try {
      final playersData = await rootBundle.loadString(
        'assets/localization/players_ar.json',
      );
      _players = jsonDecode(playersData) as Map<String, dynamic>;
    } catch (_) {
      _players = {};
    }

    _loaded = true;
  }

  /// ✅ Getters للـ Maps كـ Map<int, String>
  static Map<int, String> get allLeagues {
    if (_leagues == null) return {};
    return _leagues!.map((key, value) => MapEntry(int.parse(key), value as String));
  }

  static Map<int, String> get allTeams {
    if (_teams == null) return {};
    return _teams!.map((key, value) => MapEntry(int.parse(key), value as String));
  }

  static Map<int, String> get allPlayers {
    if (_players == null) return {};
    return _players!.map((key, value) => MapEntry(int.parse(key), value as String));
  }

  /// ✅ Methods مضمونة ترجع String
  static String leagueName(int id, [String? fallback]) {
    return allLeagues[id] ?? fallback ?? "League $id";
  }

  static String teamName(int id, [String? fallback]) {
    return allTeams[id] ?? fallback ?? "Team $id";
  }

  static String playerName(int id, [String? fallback]) {
    return allPlayers[id] ?? fallback ?? "Player $id";
  }
}
